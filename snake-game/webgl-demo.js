// Functional reconstruction from the submitted WebGL segment assignment.
const canvas=document.getElementById('canvas');
const gl=canvas.getContext('webgl');
const status=document.getElementById('status');
if(!gl){status.textContent='WebGL is not supported or is disabled in this browser.';}
else {
 const positions=new Float32Array([
 -0.5,0, 0.3,0.1, 0.5,0,
 -0.5,0.9, -0.2,0.8, 0.5,0.9,
 -0.5,-0.9, -0.4,-0.8, 0.5,-0.9,
 0.5,0.9, 0.4,0.8, 0.5,0,
 0.5,-0.9, 0.4,-0.6, 0.5,0,
 -0.5,0.9, -0.4,0.1, -0.5,0,
 -0.5,-0.9, -0.4,-0.3, -0.5,0
 ]);
 const palette=[[1,0.1,0.12],[0.19,0.92,0.41],[0.22,0.55,1],[1,0.83,0.16],[0.22,0.91,0.91],[0.85,0.31,0.97],[0.94,0.89,0.94]];
 const colors=new Float32Array(palette.flatMap(color=>[...color,...color,...color]));
 function makeShader(type,source){const sh=gl.createShader(type);gl.shaderSource(sh,source);gl.compileShader(sh);if(!gl.getShaderParameter(sh,gl.COMPILE_STATUS))throw Error(gl.getShaderInfoLog(sh));return sh;}
 try {
  const vertex=makeShader(gl.VERTEX_SHADER,'attribute vec2 coordinates; attribute vec3 colors; varying vec3 vColor; void main(){gl_Position=vec4(coordinates,0.0,1.0);vColor=colors;}');
  const frag=makeShader(gl.FRAGMENT_SHADER,'precision mediump float; varying vec3 vColor;void main(){gl_FragColor=vec4(vColor,1.0);}');
  const program=gl.createProgram();gl.attachShader(program,vertex);gl.attachShader(program,frag);gl.linkProgram(program);
  if(!gl.getProgramParameter(program,gl.LINK_STATUS))throw Error(gl.getProgramInfoLog(program));
  gl.useProgram(program);
  function addAttribute(name,data,components){const b=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,b);gl.bufferData(gl.ARRAY_BUFFER,data,gl.STATIC_DRAW);const loc=gl.getAttribLocation(program,name);gl.vertexAttribPointer(loc,components,gl.FLOAT,false,0,0);gl.enableVertexAttribArray(loc);}
  addAttribute('coordinates',positions,2);addAttribute('colors',colors,3);
  gl.viewport(0,0,canvas.width,canvas.height);gl.clearColor(0.027,0.106,0.07,1);gl.clear(gl.COLOR_BUFFER_BIT);gl.drawArrays(gl.TRIANGLES,0,positions.length/2);
  status.textContent='WebGL rendering successful · 7 coloured segments · 21 vertices';
 } catch (err){status.textContent='Graphics rendering error: '+err.message;}
}
