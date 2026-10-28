// Original score and deterministic offline stereo synthesizer. Node built-ins only.
const fs=require('fs'),path=require('path');const SR=32000,TAU=Math.PI*2;
const hz=n=>440*2**((n-69)/12);
// Hand-authored eight-note phrases. 0 = rest, -1 = sustain previous note.
const A=[
[76,-1,79,78,76,-1,71,74],[76,-1,83,-1,81,79,78,-1],
[79,-1,76,74,72,-1,74,76],[78,-1,74,-1,71,-1,74,78],
[76,79,83,-1,81,79,76,-1],[74,76,79,-1,78,76,74,-1],
[72,-1,76,79,78,-1,76,74],[71,-1,75,-1,78,-1,83,-1],
[83,-1,81,79,78,79,81,-1],[79,-1,76,-1,74,76,79,-1],
[81,-1,79,76,72,74,76,-1],[78,79,81,-1,78,75,71,-1],
[76,-1,79,-1,83,-1,86,83],[84,-1,83,79,76,-1,74,-1],
[78,-1,76,74,71,74,75,78],[76,-1,-1,-1,0,71,74,75]];
const B=[
[76,76,0,79,78,76,0,71],[75,78,83,78,75,71,0,75],
[72,76,79,76,72,71,69,71],[74,78,81,78,74,71,0,74],
[76,79,83,86,83,79,76,79],[77,81,84,81,77,76,74,72],
[75,78,83,87,83,78,75,71],[76,-1,0,76,79,78,76,75]];
const E=[
[76,-1,-1,79,83,-1,-1,-1],[81,-1,79,76,74,-1,-1,-1],
[79,-1,76,-1,72,-1,74,76],[78,-1,-1,-1,74,-1,-1,-1],
[76,-1,79,-1,83,-1,86,-1],[84,-1,83,79,76,-1,-1,-1],
[78,-1,81,-1,83,-1,78,-1],[79,-1,-1,-1,-1,-1,-1,-1]];
const chords=[[52,55,59,62],[48,52,55,59],[45,48,52,55],[47,51,54,57]];
function score(key){const cfg={opening:{bpm:112,bars:24,name:'01_星の向こうへ'},stage:{bpm:138,bars:32,name:'02_軌道の残響'},boss:{bpm:150,bars:32,name:'03_記憶の番人'},ending:{bpm:92,bars:24,name:'04_帰還の光'}}[key];const beat=60/cfg.bpm,bar=beat*4,events=[];
const add=(instrument,n,t,d,v,pan=0)=>events.push({instrument,n,t,d,v,pan});
for(let m=0;m<cfg.bars;m++){let ch=chords[m%4];if(key==='ending')ch=[[48,52,55,59],[43,47,50,55],[45,48,52,55],[41,45,48,52],[48,52,55,59],[45,48,52,55],[43,47,50,53],[48,52,55,60]][m%8];if(key==='boss'&&m%8===5)ch=[41,45,48,52];
const intro=(key==='opening'&&m<4)||(key==='ending'&&m<2),bridge=(key==='stage'&&m>=16&&m<20)||(key==='boss'&&m>=16&&m<20),outro=(key==='ending'&&m>=20);
const density=intro||bridge||outro?.55:1;const t=m*bar;
ch.forEach((n,i)=>add('pad',n,t,bar*.96,.045*density,(i-1.5)*.36));
for(let k=0;k<8;k++){if(outro&&k%2)continue;add('bell',ch[[0,2,1,3,2,1,3,2][k]]+12,t+k*beat/2,beat*.65,.04*density,k%2?.6:-.6);}
if(!intro){for(let k=0;k<8;k++){const n=ch[0]-12+(k===3||k===7?7:k===6?12:0);add('bass',n,t+k*beat/2,beat*.4,.14*density,-.05);}}
if(!intro&&!outro){for(let k=0;k<8;k++){add('hat',0,t+k*beat/2,.055,k%2?.022:.032,.25);if(k===0||k===4||(!bridge&&m%4===3&&k===7))add('kick',0,t+k*beat/2,.22,.22);if(k===2||k===6)add('snare',0,t+k*beat/2,.17,.12,-.12);}if(m%8===7&&!bridge)for(let k=0;k<4;k++)add('snare',0,t+bar-beat/2+k*beat/8,.1,.045+k*.012,(k-1.5)*.25);}
let phrase=key==='ending'?E[m%8]:key==='boss'?B[m%8]:A[(m+(key==='opening'?0:4))%16];if(intro)phrase=A[m%16].map(n=>n>0?n-12:n);
for(let k=0;k<8;k++){if(phrase[k]<=0)continue;let length=1;while(k+length<8&&phrase[k+length]===-1)length++;let pitch=phrase[k];if(key==='ending')pitch-=key==='ending'&&m<8?12:0;add(key==='ending'?'bell':'lead',pitch,t+k*beat/2,beat/2*length*.88,intro?.08:.115,-.12);if(m>=8&&!bridge&&!intro&&key!=='boss'&&k%2===0)add('counter',ch[(k/2)%4]+12,t+k*beat/2+beat/4,beat*.65,.035,.35);}
}
// Resolve album arrangement to tonic; the game loops after the resolution.
const end=cfg.bars*bar;const tonic=key==='ending'?[48,52,55,60]:[52,55,59,64];tonic.forEach((n,i)=>add('pad',n,end,2.4,.065,(i-1.5)*.3));add('bell',key==='ending'?79:76,end,2,.1);return {...cfg,events,duration:end+3.2};}
function render(key){const song=score(key),N=Math.ceil(song.duration*SR),L=new Float32Array(N),R=new Float32Array(N);let seed=1337;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)|0;return (seed>>>0)/2147483648-1;};
for(const e of song.events){const start=Math.floor(e.t*SR),len=Math.ceil((e.d+.16)*SR),f=hz(e.n);let phase=0,low=0;const left=Math.cos((e.pan+1)*Math.PI/4),right=Math.sin((e.pan+1)*Math.PI/4);
for(let j=0;j<len&&start+j<N;j++){const t=j/SR,release=Math.min(1,Math.max(0,1-(t-e.d)/.16)),attack=Math.min(1,t/(e.instrument==='pad'?.06:.006));let env=attack*release,s=0;const v=e.instrument;
if(v==='kick'){s=Math.sin(TAU*(44*t+110*.025*(1-Math.exp(-t/.025))))*Math.exp(-t*19);}
else if(v==='snare'||v==='hat'){const n=random();low+=.14*(n-low);s=(n-low)*Math.exp(-t*(v==='hat'?65:26));if(v==='snare')s+=.35*Math.sin(TAU*180*t)*Math.exp(-t*32);}
else{phase+=f/SR*(1+(v==='lead'?.002*Math.sin(TAU*5.4*t):0));const q=phase*TAU;
if(v==='lead'){s=Math.sin(q)+.33*Math.sin(3*q)+.15*Math.sin(5*q);s*=.7*(.72+.28*Math.exp(-t*15));}
else if(v==='bass')s=(Math.sin(q)+.12*Math.sin(3*q))*.9;
else if(v==='pad')s=(Math.sin(q)+.25*Math.sin(q*1.002)+.13*Math.sin(q*2))*.6;
else if(v==='counter')s=(Math.sin(q)+.2*Math.sin(q*2))*.8;
else s=(Math.sin(q)+.25*Math.sin(q*2)+.1*Math.sin(q*3))*Math.exp(-t*3.8);
}const value=s*env*e.v;L[start+j]+=value*left;R[start+j]+=value*right;}}
// Cross-channel short ambience + tempo-related echo. No external samples.
for(const [delay,g] of [[.041,.10],[.073,.08],[60/song.bpm*.75,.14],[60/song.bpm*1.5,.07]]){const d=Math.round(delay*SR);for(let i=N-1;i>=d;i--){const l=L[i-d],r=R[i-d];L[i]+=r*g;R[i]+=l*g;}}
let peak=0,sum=0;for(let i=0;i<N;i++){peak=Math.max(peak,Math.abs(L[i]),Math.abs(R[i]));}const scale=.88/Math.max(peak,.01);const wav=Buffer.alloc(44+N*4);wav.write('RIFF',0);wav.writeUInt32LE(wav.length-8,4);wav.write('WAVEfmt ',8);wav.writeUInt32LE(16,16);wav.writeUInt16LE(1,20);wav.writeUInt16LE(2,22);wav.writeUInt32LE(SR,24);wav.writeUInt32LE(SR*4,28);wav.writeUInt16LE(4,32);wav.writeUInt16LE(16,34);wav.write('data',36);wav.writeUInt32LE(N*4,40);for(let i=0;i<N;i++){const fade=Math.min(1,i/(SR*.015),(N-1-i)/(SR*.8));for(let c=0;c<2;c++){const value=(c?R[i]:L[i])*scale*fade;sum+=value*value;wav.writeInt16LE(Math.round(Math.max(-1,Math.min(1,value))*32767),44+i*4+c*2);}}
const file=path.join(__dirname,key+'.wav');fs.writeFileSync(file,wav);return {key,title:song.name,bpm:song.bpm,bars:song.bars,duration:song.duration,events:song.events.length,peakBeforeNormalization:peak,peakLimit:.88,rms:Math.sqrt(sum/(N*2)),bytes:wav.length};}
if(require.main===module){const report=['opening','stage','boss','ending'].map(key=>{const result=render(key);console.log(JSON.stringify(result));return result;});fs.writeFileSync(path.join(__dirname,'audio-analysis.json'),JSON.stringify(report,null,2));}
module.exports={score,render};
