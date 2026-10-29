// Run from a repository checkout: node tools/build_story_music.cjs
const fs=require('fs'),path=require('path');
const root=path.resolve(__dirname,'..');
const renderer=path.join(root,'browser-prototype/music/render.cjs');
if(!fs.existsSync(renderer))throw Error('browser-prototype/music/render.cjs が必要です');
const {render}=require(renderer);
for(const [track,target] of Object.entries({opening:'title',stage:'ruins',boss:'sentinel',ending:'ending'})){
  const report=render(track);
  fs.copyFileSync(path.join(path.dirname(renderer),track+'.wav'),path.join(root,'audio',target+'.wav'));
  console.log(target,report.duration.toFixed(2)+'s');
}
console.log('Godotで再インポートしてから起動・PCK生成してください。');
