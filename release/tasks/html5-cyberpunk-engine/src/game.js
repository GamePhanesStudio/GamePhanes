const enemyTypes=['drone','tank'];
function createGame(){return{enemies:[],update(){},draw(){}};}
if(typeof module!=='undefined')module.exports={enemyTypes,createGame};