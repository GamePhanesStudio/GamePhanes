function createState(){return{score:0,hp:3,wave:0,mode:'running'};}
function transition(state,event){if(event==='damage')state.hp=Math.max(0,state.hp-1);if(event==='wave')state.wave+=1;if(state.hp===0)state.mode='gameover';return state;}
if(typeof window!=='undefined')window.CyberState={createState,transition};
if(typeof module!=='undefined')module.exports={createState,transition};
