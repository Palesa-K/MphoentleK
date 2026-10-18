// Based on the supplied CGD260S Snake assignment; adjusted for reliable play and mobile controls.
const gameBoard = document.getElementById('game-board');
const instructionText = document.getElementById('instruction-text');
const gameMessage = document.getElementById('game-message');
const scoreElement = document.getElementById('score');
const highScoreElement = document.getElementById('highScore');
const restartButton = document.getElementById('restart-button');
const startButton = document.getElementById('start-button');
const overlay = document.getElementById('overlay');
const gameLevel = document.getElementById('gamelevel');
const gridSize = 20;
let snake, food, direction, queuedDirection, gameInterval, gameSpeedDelay, gameStarted, gameOver, highScore = 0;
try { highScore = Number(localStorage.getItem('snake-high-score') || 0) || 0; } catch (_) {}
highScoreElement.textContent = String(highScore).padStart(3, '0');
function resetState() {
  clearInterval(gameInterval); gameInterval = undefined;
  snake = [{x:10,y:10}]; direction='right'; queuedDirection='right';
  gameSpeedDelay=200; gameStarted=false; gameOver=false;
  food=generateFood(); draw();
  gameLevel.textContent='Level 1 · Normal';
}
function generateFood() {
  const choices = [];
  for(let y=1;y<=gridSize;y++) for(let x=1;x<=gridSize;x++)
    if(!snake.some(s=>s.x===x && s.y===y)) choices.push({x,y});
  return choices.length ? choices[Math.floor(Math.random()*choices.length)] : null;
}
function setPosition(el, p) { el.style.gridColumn=p.x; el.style.gridRow=p.y; }
function draw() {
  gameBoard.replaceChildren();
  snake.forEach((segment,i)=>{const el=document.createElement('div'); el.className=i?'snake':'snake snake-head'; setPosition(el,segment);gameBoard.appendChild(el);});
  if(food && gameStarted){const f=document.createElement('div'); f.className='food';setPosition(f,food);gameBoard.appendChild(f);}
  scoreElement.textContent=String(snake.length-1).padStart(3,'0');
}
function showOverlay(title, message, button) {instructionText.textContent=title;gameMessage.textContent=message;startButton.textContent=button;overlay.hidden=false;}
function startGame() { resetState(); gameStarted=true; overlay.hidden=true; draw(); gameInterval=setInterval(move,gameSpeedDelay); }
function finishGame(message) {
  clearInterval(gameInterval); gameInterval=undefined;gameStarted=false; gameOver=true;
  const score=snake.length-1; if(score>highScore){highScore=score;try{localStorage.setItem('snake-high-score',String(highScore))}catch(_){}}
  highScoreElement.textContent=String(highScore).padStart(3,'0');
  draw();showOverlay(message,`Your score: ${score}`, 'Play again');
}
function move() {
  if(!gameStarted)return;
  direction=queuedDirection;
  const head={...snake[0]};
  if(direction==='up')head.y--;else if(direction==='down')head.y++;else if(direction==='left')head.x--;else head.x++;
  const ate=food && head.x===food.x && head.y===food.y;
  // Moving into the old tail square is allowed when the snake is not growing.
  const bodyToCheck=ate?snake:snake.slice(0,-1);
  const hitWall=head.x<1||head.x>gridSize||head.y<1||head.y>gridSize;
  const hitSelf=bodyToCheck.some(seg=>seg.x===head.x&&seg.y===head.y);
  if(hitWall||hitSelf){finishGame('Game over');return;}
  snake.unshift(head); if(!ate)snake.pop();
  if(ate){food=generateFood();gameSpeedDelay=Math.max(100,gameSpeedDelay-5);
    clearInterval(gameInterval);gameInterval=setInterval(move,gameSpeedDelay);
    gameLevel.textContent=`Level ${1+Math.floor((snake.length-1)/5)} · ${gameSpeedDelay} ms / move`;
    if(!food){finishGame('You filled the board!');return;}}
  draw();
}
function changeDirection(next) {
  const opposites={left:'right',right:'left',up:'down',down:'up'};
  if(next !== opposites[direction])queuedDirection=next;
}
document.addEventListener('keydown',e=>{
 if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space'].includes(e.code))e.preventDefault();
 if((e.code==='Space'||e.key===' ')&&!gameStarted){startGame();return;}
 if(e.key.startsWith('Arrow'))changeDirection(e.key.slice(5).toLowerCase());
});
document.querySelectorAll('[data-dir]').forEach(btn=>btn.addEventListener('click',()=>changeDirection(btn.dataset.dir)));
startButton.addEventListener('click',startGame);restartButton.addEventListener('click',startGame);
resetState();showOverlay('Press SPACE to start','Use the arrow keys to move','Start game');
