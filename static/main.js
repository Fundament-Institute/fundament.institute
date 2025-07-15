function addEvent(elem, type, eventHandle) {
  if (elem == null || elem == undefined) return;
  if (elem.addEventListener) {
    elem.addEventListener(type, eventHandle, false);
  } else if (elem.attachEvent) {
    elem.attachEvent("on" + type, eventHandle);
  } else {
    elem["on" + type] = eventHandle;
  }
};

function createShader(gl, source, type) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    const info = gl.getShaderInfoLog(shader);
    throw new Error(`Could not compile WebGL program.\n\n${info}`);
  }

  return shader;
}

function linkProgram(gl, vertexShader, fragmentShader) {
  const program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    const info = gl.getProgramInfoLog(program);
    throw new Error(`Could not compile WebGL program.\n\n${info}`);
  }

  return program;
}

function createWebGLProgramFromIds(gl, vertexSourceId, fragmentSourceId) {
  const vertexSourceEl = document.getElementById(vertexSourceId);
  const fragmentSourceEl = document.getElementById(fragmentSourceId);

  const vertexShader = createShader(gl, vertexSourceEl.innerHTML, gl.VERTEX_SHADER);
  const fragmentShader = createShader(gl, fragmentSourceEl.innerHTML, gl.FRAGMENT_SHADER);
  return linkProgram(gl, vertexShader, fragmentShader);
}

// Define the data that is needed to make a 3d cube
function createCubeData() {
  const MAX_WIDTH = 2.0;
  const MAX_DEPTH = 100.0;
  const DEPTH_STEP = 1.0;
  const LINE_STEP = 0.01;
  const LINE_HEIGHT = 0.5;

  let positions = [];

  for (let z = 10.0; z <= MAX_DEPTH; z += DEPTH_STEP) {
    for (let x = -MAX_WIDTH; x < MAX_WIDTH; x += LINE_STEP) {
      positions.push(x * z, -1.0 * 1, -z, (x + LINE_STEP) * z);
      positions.push(x * z, 1.0 * 2, -z, (x + LINE_STEP) * z);
      positions.push((x + LINE_STEP) * z, 1.0 * 3, -z, (x + LINE_STEP * 2) * z);
      positions.push(x * z, -1.0 * 4, -z, (x + LINE_STEP) * z);
      positions.push((x + LINE_STEP) * z, 1.0 * 5, -z, (x + LINE_STEP * 2) * z);
      positions.push((x + LINE_STEP) * z, -1.0 * 6, -z, (x + LINE_STEP * 2) * z);
    }
  }

  return { positions };
}

// Take the data for a cube and bind the buffers for it.
// Return an object collection of the buffers
function createBuffersForCube(gl, cube) {
  const positions = gl.createBuffer();
  const len = cube.positions.length / 4;
  gl.bindBuffer(gl.ARRAY_BUFFER, positions);
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array(cube.positions),
    gl.STATIC_DRAW,
  );

  return { positions, len };
}
function perspective(fieldOfViewInRadians, aspectRatio, near, far) {
  const f = 1.0 / Math.tan(fieldOfViewInRadians / 2);
  const rangeInv = 1 / (near - far);

  // prettier-ignore
  return [
    f / aspectRatio, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (near + far) * rangeInv, -1,
    0, 0, near * far * rangeInv * 2, 0,
  ];
}
class CubeDemo {
  canvas = document.getElementById("bgeffect");
  gl = this.canvas.getContext("webgl");
  webglProgram = createWebGLProgramFromIds(
    this.gl,
    "vertex-shader",
    "fragment-shader",
  );
  transforms = {}; // All of the matrix transforms
  locations = {}; // All of the shader locations
  buffers;

  constructor() {
    const gl = this.gl;
    const canvas = this.canvas;
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.useProgram(this.webglProgram);
    this.buffers = createBuffersForCube(gl, createCubeData());

    // Save the attribute and uniform locations
    this.locations.time = gl.getUniformLocation(this.webglProgram, "time");
    this.locations.model = gl.getUniformLocation(this.webglProgram, "model");
    this.locations.projection = gl.getUniformLocation(
      this.webglProgram,
      "projection",
    );
    this.locations.position = gl.getAttribLocation(
      this.webglProgram,
      "position",
    );

    //gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE)
    addEvent(window, "resize", function (event) {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      gl.viewport(0, 0, canvas.width, canvas.height);
    });
  }

  computePerspectiveMatrix(scaleFactor) {
    const fieldOfViewInRadians = Math.PI * 0.5;
    const aspectRatio = window.innerWidth / window.innerHeight;
    const nearClippingPlaneDistance = 1;
    const farClippingPlaneDistance = 50;

    this.transforms.projection = perspective(
      fieldOfViewInRadians,
      aspectRatio,
      nearClippingPlaneDistance,
      farClippingPlaneDistance,
    );
  }

  draw() {
    const gl = this.gl;
    const now = Date.now();
    // Compute our matrices
    this.computePerspectiveMatrix(0.5);
    // Update the data going to the GPU
    // Setup the color uniform that will be shared across all triangles
    gl.uniformMatrix4fv(
      this.locations.projection,
      false,
      new Float32Array(this.transforms.projection),
    );
    gl.uniform1f(
      this.locations.time,
      performance.now()
    );


    // Set the positions attribute
    gl.enableVertexAttribArray(this.locations.position);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.buffers.positions);
    gl.vertexAttribPointer(this.locations.position, 4, gl.FLOAT, false, 0, 0);

    // Perform the actual draw
    gl.drawArrays(gl.TRIANGLES, 0, this.buffers.len);
    // Run the draw as a loop
    requestAnimationFrame(() => this.draw());
  }
}


const cube = new CubeDemo();
cube.draw();
