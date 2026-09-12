const enemyTypes=['drone','tank','wisp','razor'];
const bossTypes=['overmind','phantom','leviathan'];
function createGame(){const s={score:0,hp:3,wave:0,enemies:[],elapsed:0};return{enemies:s.enemies,update(dt){s.elapsed+=dt;if(s.elapsed>.25&&s.enemies.length<8){s.enemies.push({type:enemyTypes[s.wave%enemyTypes.length],x:160,y:20});s.wave++;}},draw(ctx,w,h){ctx.fillStyle='#050510';ctx.fillRect(0,0,w,h);ctx.fillStyle='#0ff';ctx.fillRect(w/2-4,h-24,8,8);for(const e of s.enemies){ctx.fillStyle='#f0f';ctx.fillRect(e.x,e.y,8,8);}},snapshot(){return{score:s.score,hp:s.hp,wave:s.wave,enemyTypes,bossTypes}}};}
if(typeof window!=='undefined')window.NeonRift={createGame,enemyTypes,bossTypes};
if(typeof module!=='undefined')module.exports={createGame,enemyTypes,bossTypes};