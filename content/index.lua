local top = requirehtml 'top'
local nav = requirehtml 'nav'
local bottom = requirehtml 'bottom'
local site = require 'site'
local G = require 'gen'
local postbox = requirehtml 'postbox'

return function(posts, authors)
  local max = 2
  max = math.min(#posts, 1+max)
  local boxed = {}
  for k=2,max do
    _G.table.insert(boxed, div { class="box", postbox(posts[k], authors)})
  end

  local archives = {}
  for k=max + 1,math.min(#posts, max + 9) do
    _G.table.insert(archives, li { a { href="/posts/"..posts[k].slug, posts[k].title}})
  end

  return html {
    top("Home", "/", site.fs, nil, 
  script { id="fragment-shader", type="x-shader/x-fragment", [[
  #ifdef GL_ES
    precision highp float;
  #endif

  varying vec4 vColor;
  varying vec3 uvw;

  void main() {
    //gl_FragColor = vec4(uvw.x, uvw.y, 0.0, 1.0);
    float warp = 1.0 - (abs(uvw.x - 0.5) * 2.0);
    float deflection = uvw.z * -10.0;
    float y = uvw.y + (warp * deflection);
    float dist = abs(y - 0.5) * 2.0;
    dist = 1.0 - clamp(dist * 3.0, 0.0, 1.0);
    gl_FragColor = vec4(dist);
  }
  ]] },
  script { id="vertex-shader", type="x-shader/x-vertex", [[
  attribute vec4 position;
  uniform mat4 projection;
  uniform float time;
  varying vec4 vColor;
  varying vec3 uvw;

  const float PI = 3.141592653589;

  float wave(float L, float A, float S, vec2 D, vec3 pos) {
    float w = (2.0*PI)/L;
    w = (sin(dot(normalize(D),vec2(pos.x,pos.z))*w + time*(S*w))+1.0)*0.5;
    return A*(w*w-1.0)*2.0;
  }

  float addy(vec3 pos) {
    float y=wave(10.0,0.15,0.001,vec2(1.0,2.0),pos);
    y+=wave(5.0,0.1,0.0005,vec2(1.0,1.0),pos);
    y+=wave(20.0,0.15,0.002,vec2(-1.0,1.0),pos);
    y+=wave(20.0,0.15,0.0015,vec2(-1.2,-1.0),pos);
    y+=wave(40.0,0.75,0.0005,vec2(1.9,-1.0),pos);
    return y;
  }

  //float modulo(float x, float m) {
  //  float v = (x / m);
  //  return (v - floor(v)) * m;
  //}

//const UNITX = array(0.0, 1.0, 0.0, 1.0, 1.0, 0.0);
//const UNITY = array(0.0, 0.0, 1.0, 0.0, 1.0, 1.0);

  void main() {
    vColor = vec4(1.0,1.0,1.0,1.0);
    int idx = int(abs(position.y));
    vec3 pos = vec3(position.x, (position.y / abs(position.y))*0.5 - 5.0, position.z);
    vec2 xz = vec2(pos.x, pos.z);
    float sample1 = addy(pos);
    float sample2 = addy(vec3((position.x + position.w) * 0.5, pos.y, pos.z));
    float sample3 = addy(vec3(position.w, pos.y, pos.z));
    pos.y += sample1 * 10.0;
    vec2 uv;

    if (idx == 1) {
    uv = vec2(0.0,1.0);
    } else if (idx == 2) {
    uv = vec2(0.0,0.0);
    } else if (idx == 3) {
    uv = vec2(1.0,0.0);
    } else if (idx == 4) {
    uv = vec2(0.0,1.0);
    } else if (idx == 5) {
    uv = vec2(1.0,0.0);
    } else if (idx == 6) {
    uv = vec2(1.0,1.0);
    }

    // The deflection here is the difference between the linear average between 1 and 3 and the true sample at point 2
    uvw = vec3(uv.x, uv.y, ((sample1 + sample3) * 0.5) - sample2);
    gl_Position = projection * vec4(pos, 1.0);
  }
  ]] },
  script { defer="", src="/main.js" }),
    body {
      header { 
      nav(site.fs.navbar),
      },
      main { 
        section { 
          id = "introbox",
          canvas { id="bgeffect"},
          h3 { "Fundament Research Institute" },
          h4 { "Progress for people, not profits" },
        },
        hr{},
        section { 
          class = "featurebox",
          div { class="wrapfeather", 
            div { class="toplayer" },
            div{ style="margin: 0 auto 2em auto;max-width:38em;padding: 0 1em;", img { class="feather", src="/img/feather.svg", alt="Feather UI" } }, 
            h4 { "Feather is a platform-independent UI library using reactive event streams and persistent functions to efficiently map application state to an interactive graphical view. It's built in Rust, and uses a lua-based DSL to specify layouts."},
            h3 { i { class="fa fa-github fa-fw" }, a { href="https://github.com/Fundament-Institute/feather-ui", "GitHub&nbsp;&#10095;" } },
            h3 { i { class="fa fa-user fa-fw" },a { href="https://opencollective.com/feather-ui", "Collective&nbsp;&#10095;" } },
            h3 { [[<svg xmlns="http://www.w3.org/2000/svg" height="32" width="32" viewBox="0 0 512 512" role="img" aria-hidden="true" id="crates"><path fill="currentColor" d="M509.5 184.6L458.9 32.8C452.4 13.2 434.1 0 413.4 0H98.6c-20.7 0-39 13.2-45.5 32.8L2.5 184.6c-1.6 4.9-2.5 10-2.5 15.2V464c0 26.5 21.5 48 48 48h416c26.5 0 48-21.5 48-48V199.8c0-5.2-.8-10.3-2.5-15.2zM32 199.8c0-1.7.3-3.4.8-5.1L83.4 42.9C85.6 36.4 91.7 32 98.6 32H240v168H32v-.2zM480 464c0 8.8-7.2 16-16 16H48c-8.8 0-16-7.2-16-16V232h448v232zm0-264H272V32h141.4c6.9 0 13 4.4 15.2 10.9l50.6 151.8c.5 1.6.8 3.3.8 5.1v.2z"></path></svg>]], a { href="https://crates.io/crates/feather-ui", "crates.io&nbsp;&#10095;" } },
          },
        },
        hr{},
        section { 
          class = "featurebox",
          div { class="wrapalicorn", 
            [[<svg width="100%" height="100%" style="position: absolute;top: 0;left: 0;">
  <pattern id="patgrid" x="0" y="0" width="6" height="6" patternUnits="userSpaceOnUse">
    <rect x="0" width="3" height="3" y="0" fill="#00090f"></rect>
    <rect fill="#00090f" x="3" width="3" height="3" y="3"></rect>
  </pattern>
  <rect x="0" y="0" width="100%" height="100%" fill="url(#patgrid)"></rect></svg>]],
            div{ style="margin: 0 auto;max-width:576px;padding: 0 14px;position:relative;", img { class="alicorn", src="/img/alicorn.svg", alt="Alicorn" } },
            h4 { "A safe, high performance programming language without compromising abstraction and convenience. Designed to maintain safety guarantees while providing access to performance primitives by using novel metaprogramming systems that allow combining implicit behaviors that get out of your way and detailed specifications of exactly how to do something most efficiently, connected by a powerful type system to catch mistakes early and let you say what you mean."},
            h3 { i { class="fa fa-github fa-fw" }, a { href="https://github.com/Fundament-Institute/alicorn0", "GitHub&nbsp;&#10095;" } },
            h3 { i { class="fa fa-user fa-fw" },a { href="https://opencollective.com/alicorn", "Collective&nbsp;&#10095;" } },
            h3 { [[<svg xmlns="http://www.w3.org/2000/svg" height="32" width="32" viewBox="0 0 512 512" role="img" aria-hidden="true" id="crates"><path fill="currentColor" d="M509.5 184.6L458.9 32.8C452.4 13.2 434.1 0 413.4 0H98.6c-20.7 0-39 13.2-45.5 32.8L2.5 184.6c-1.6 4.9-2.5 10-2.5 15.2V464c0 26.5 21.5 48 48 48h416c26.5 0 48-21.5 48-48V199.8c0-5.2-.8-10.3-2.5-15.2zM32 199.8c0-1.7.3-3.4.8-5.1L83.4 42.9C85.6 36.4 91.7 32 98.6 32H240v168H32v-.2zM480 464c0 8.8-7.2 16-16 16H48c-8.8 0-16-7.2-16-16V232h448v232zm0-264H272V32h141.4c6.9 0 13 4.4 15.2 10.9l50.6 151.8c.5 1.6.8 3.3.8 5.1v.2z"></path></svg>]], a { href="https://crates.io/crates/alicorn", "crates.io&nbsp;&#10095;" } },
          },
        },
        hr{},
        postbox(posts[1], authors, true),
        hr{},
        div(append({ class="grid", },
          boxed,
          { 
            div { class="box",
              section { 
                h6 [[ARCHIVES]],
                hr{},
                article { 
                  ul(archives)
                },
                hr{},
                a { class="archivebutton", href="/posts/", [[Browse Articles ...]] }
              }
            }
          })),
      },
      bottom(site.fs.name),
    }
  }
end
