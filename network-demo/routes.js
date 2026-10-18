(() => {
  'use strict';
  const data = window.NETWORK_DATA;
  const sourceSelect = document.querySelector('#source');
  const targetSelect = document.querySelector('#target');
  const info = document.querySelector('#result');
  const svg = document.querySelector('#network-svg');
  if (!data || !sourceSelect || !targetSelect || !svg) return;
  const N = 32;
  const NS = 'http://www.w3.org/2000/svg';
  const graph = new Map(data.nodes.map(n => [n, []]));
  data.links.forEach(e => {
    graph.get(e.source).push([e.target, e.weight]);
    graph.get(e.target).push([e.source, e.weight]);
  });
  const angles = new Map(data.nodes.map((n, i) => {
    const a = (2*Math.PI*(i/N)) - Math.PI/2;
    return [n, {x:450 + 358*Math.cos(a), y:350 + 277*Math.sin(a)}];
  }));
  function el(tag, attributes, text) {
    const element = document.createElementNS(NS,tag);
    for (const [name,value] of Object.entries(attributes)) element.setAttribute(name,String(value));
    if (text!==undefined) element.textContent=String(text);
    return element;
  }
  function shortest(start,end) {
    const distances = new Map(data.nodes.map(n=>[n,Infinity]));
    const previous = new Map(), seen = new Set();distances.set(start,0);
    while (seen.size < N) {
      let best=null;
      for(const node of data.nodes) if(!seen.has(node) && (best===null || distances.get(node)<distances.get(best))) best=node;
      if(best===null || !Number.isFinite(distances.get(best))) break;
      if(best===end) break;
      seen.add(best);
      for(const [next,w] of graph.get(best)) {
        const test=distances.get(best)+w;
        if(test<distances.get(next)) {distances.set(next,test);previous.set(next,best);}
      }
    }
    if(!Number.isFinite(distances.get(end)))return {path:[],cost:null};
    const path=[end];
    while(path[0]!==start) {const node=previous.get(path[0]);if(node===undefined) return {path:[],cost:null};path.unshift(node);}
    return {path,cost:distances.get(end)};
  }
  for(const node of data.nodes) {
    for(const [select,chosen] of [[sourceSelect,32],[targetSelect,1]]) {
      const option=document.createElement('option');option.value=String(node);option.textContent=`Node ${node}`;option.selected=node===chosen;select.append(option);
    }
  }
  function render() {
    const source=Number(sourceSelect.value), target=Number(targetSelect.value);
    const {path,cost}=shortest(source,target);
    info.textContent=cost===null?'No path exists.':`Minimum-weight route: ${path.join(' → ')}   •   Total link weight: ${cost}   •   Hops: ${path.length-1}`;
    svg.replaceChildren();
    svg.append(el('rect',{x:0,y:0,width:900,height:700,fill:'#f9fcfa'}));
    const highlighted=new Set(path.slice(1).map((n,i)=>[n,path[i]].sort((a,b)=>a-b).join('-')));
    data.links.forEach(edge=>{
      const u=angles.get(edge.source),v=angles.get(edge.target);
      svg.append(el('line',{x1:u.x,y1:u.y,x2:v.x,y2:v.y,stroke:'#b3c8ba','stroke-width':1.45,opacity:.55}));
    });
    data.links.forEach(edge=>{
      const key=[edge.source,edge.target].sort((a,b)=>a-b).join('-');
      if(!highlighted.has(key))return;
      const u=angles.get(edge.source),v=angles.get(edge.target);
      svg.append(el('line',{x1:u.x,y1:u.y,x2:v.x,y2:v.y,stroke:'#147a43','stroke-width':6,'stroke-linecap':'round'}));
    });
    data.nodes.forEach(n=>{
      const p=angles.get(n);const inPath=path.includes(n);
      svg.append(el('circle',{cx:p.x,cy:p.y,r:inPath?16:14,fill:inPath?'#147a43':'#edf7ef',stroke:inPath?'#0b5f37':'#549470','stroke-width':2}));
      svg.append(el('text',{x:p.x,y:p.y+4,'text-anchor':'middle','font-size':11,'font-weight':'bold',fill:inPath?'#ffffff':'#164b30'},n));
    });
  }
  sourceSelect.addEventListener('change',render);targetSelect.addEventListener('change',render);render();
})();
