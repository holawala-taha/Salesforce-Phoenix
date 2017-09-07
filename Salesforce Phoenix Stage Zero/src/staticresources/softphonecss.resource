html, body, div, span, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
abbr, address, cite, code,
del, dfn, em, img, ins, kbd, q, samp,
small, strong, sub, sup, var,
b, i,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section, summary,
time, mark, audio, video {
    margin:0;
    padding:0;
    border:0;
    outline:0;
    font-size:100%;
    vertical-align:baseline;
    background:transparent;
}

body {
    line-height:1;
}

article,aside,details,figcaption,figure,
footer,header,hgroup,menu,nav,section { 
    display:block;
}

nav ul {
    list-style:none;
}

blockquote, q {
    quotes:none;
}

blockquote:before, blockquote:after,
q:before, q:after {
    content:'';
    content:none;
}

a {
    margin:0;
    padding:0;
    font-size:100%;
    vertical-align:baseline;
    background:transparent;
}

/* change colours to suit your needs */
ins {
    background-color:#ff9;
    color:#000;
    text-decoration:none;
}

/* change colours to suit your needs */
mark {
    background-color:#ff9;
    color:#000; 
    font-style:italic;
    font-weight:bold;
}

del {
    text-decoration: line-through;
}

abbr[title], dfn[title] {
    border-bottom:1px dotted;
    cursor:help;
}

table {
    border-collapse:collapse;
    border-spacing:0;
}

/* change border colour to suit your needs */
hr {
    display:block;
    height:1px;
    border:0;   
    border-top:1px solid #cccccc;
    margin:1em 0;
    padding:0;
}

input, select {
    
}


.clearfix:before, .clearfix:after { content: " "; display: table; }
.clearfix:after { clear: both; }
.clearfix { *zoom: 1; }

*, *:before, *:after {
  -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box;
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}

body {
  font-family: "Helvetica", Arial, sans-serif;
  background-color: white;
}

#softphone {
  width: 175px;
  margin: 10px auto 0px;
}

#agent-status-controls {
  margin: 10px 0 20px;
  position: relative;
}

.agent-status {
  border: none;
  padding: 6px 10px;
  background-image: linear-gradient(bottom, #ddd 20%, #eee 72%);
  background-image: -o-linear-gradient(bottom, #ddd 20%, #eee 72%);
  background-image: -moz-linear-gradient(bottom, #ddd 20%, #eee 72%);
  background-image: -webkit-linear-gradient(bottom, #ddd 20%, #eee 72%);
  background-image: -ms-linear-gradient(bottom, #ddd 20%, #eee 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #ddd), color-stop(0.72, #eee));
  color: #333;
  text-shadow: 0px -1px 0px rgba(255, 255, 255, 0.3);
  box-shadow: inset 0px 0px 1px rgba(0, 0, 0, 0.4);
  cursor: pointer;
  text-align: center;
}

button.agent-status {
  display: inline-block;
  float: left;
  width: 50%;
  margin: 0;
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
}

@-webkit-keyframes pulse {
  0% {background-color: #EA6045;}
  50% {background-color: #e54a23;}
  100% {background-color: #EA6045;}
}

div.agent-status {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
  font-size: 12px;
  line-height: 12px;
  background-image: none;
  background-color: #EA6045;
  -webkit-animation: pulse 1s infinite alternate;
  color: #fff;
  text-shadow: 0px -1px 0px rgba(0, 0, 0, 0.2);
  border-radius: 2px;
}

.agent-status:active, .agent-status:focus {
  outline: none;
}

.agent-status[disabled] {
  box-shadow: inset 0px 0px 15px rgba(0, 0, 0, 0.6);
  opacity: 0.8;
  text-shadow: 0px 1px 0px rgba(0, 0, 0, 0.4);
}

.agent-status.ready {
  border-radius: 2px 0 0 2px;
}

.agent-status.ready[disabled] {
  background-image: linear-gradient(bottom, #7eac20 20%, #91c500 72%);
  background-image: -o-linear-gradient(bottom, #7eac20 20%, #91c500 72%);
  background-image: -moz-linear-gradient(bottom, #7eac20 20%, #91c500 72%);
  background-image: -webkit-linear-gradient(bottom, #7eac20 20%, #91c500 72%);
  background-image: -ms-linear-gradient(bottom, #7eac20 20%, #91c500 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #7eac20), color-stop(0.72, #91c500));
  color: #f5f5f5;
}

.agent-status.not-ready {
  border-radius: 0 2px 2px 0;
}

.agent-status.not-ready[disabled] {
  background-image: linear-gradient(bottom, #e64118 20%, #e54a23 72%);
  background-image: -o-linear-gradient(bottom, #e64118 20%, #e54a23 72%);
  background-image: -moz-linear-gradient(bottom, #e64118 20%, #e54a23 72%);
  background-image: -webkit-linear-gradient(bottom, #e64118 20%, #e54a23 72%);
  background-image: -ms-linear-gradient(bottom, #e64118 20%, #e54a23 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #e64118), color-stop(0.72, #e54a23));
  color: #f5f5f5;
}

#dialer {
  border: solid 1px #ddd;
  border-width: 0 0 0 1px;
  -webkit-transition: opacity 1s;
  transition: opacity 1s;
}



#number-entry {
  position: relative;
  height: 48px;
}

.incoming input {
  border: solid 1px red;
}

.incoming #dialer {
  opacity: 0.25;
}

.softphone .incoming-call-status {
  position: absolute;
  display: none;
  top: 100%;
  left: 0;
  right: 0;
  background: red;
  color: #fff;
  font-size: 16px;
  padding: 6px 0;
  text-align: center;
  width: 100%;
  z-index: 200;
  border-radius: 0 0 2px 2px;
  opacity: 0;
  -webkit-transition: opacity 1s;
  transition: opacity 1s;
}

.incoming .incoming-call-status {
  display: block;
  opacity: 1;
}

.number {
  color: #555;
  font-weight: 300;
  cursor: pointer;
  display: inline-block;
  height: 38px;
  line-height: 38px;
  font-size: 21px;
  width: 33.333333333%;
  background-image: linear-gradient(bottom, #e9e9e9 20%, #e5e5e5 72%);
  background-image: -o-linear-gradient(bottom, #e9e9e9 20%, #e5e5e5 72%);
  background-image: -moz-linear-gradient(bottom, #e9e9e9 20%, #e5e5e5 72%);
  background-image: -webkit-linear-gradient(bottom, #e9e9e9 20%, #e5e5e5 72%);
  background-image: -ms-linear-gradient(bottom, #e9e9e9 20%, #e5e5e5 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #e9e9e9), color-stop(0.72, #e5e5e5));
  text-shadow: 0px 1px 0px #f5f5f5;
  filter: dropshadow(color=#f5f5f5, offx=0, offy=1);
  text-align: center;
  box-shadow: inset 1px 0px 0px rgba(255, 255, 255, 0.4),
    inset -1px 0px 0px rgba(0, 0, 0, 0.1),
    inset 0px 1px 0px #f5f5f5,
    inset 0 -1px 0px #d6d6d6;
}

.number.ast {
  font-size: 33px;
  line-height: 32px;
  vertical-align: -1px;
}

.number:hover {
  background-image: linear-gradient(bottom, #E3F9F9 20%, #72B6CC 72%);
  background-image: -o-linear-gradient(bottom, #E3F9F9 20%, #72B6CC 72%);
  background-image: -moz-linear-gradient(bottom, #E3F9F9 20%, #72B6CC 72%);
  background-image: -webkit-linear-gradient(bottom, #E3F9F9 20%, #72B6CC 72%);
  background-image: -ms-linear-gradient(bottom, #E3F9F9 20%, #72B6CC 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #72B6CC), color-stop(0.72, #f0f0f0));
}

.mute:active,.save:active,.call:active,.hangup:active,.number:active {
  box-shadow: inset 1px 0px 0px rgba(255, 255, 255, 0.4),
    inset -1px 0px 0px rgba(0, 0, 0, 0.1),
    inset 0px 1px 0px #f5f5f5,
    inset 0 -1px 0px #d6d6d6,
    inset 0px 0px 5px 2px rgba(0, 0, 0, 0.15);
}

#action-buttons button {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  display: inline-block;
  border: none;
  margin: 0;
  cursor: pointer;
}

#action-buttons .call {
  color: #f5f5f5;
  width: 100%;
  font-size: 18px;
  padding: 8px 0;
  text-shadow: 0px -1px 0px rgba(0, 0, 0, 0.3);
  margin: 0;
  background-image: linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -o-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -moz-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -webkit-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -ms-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #1797c0), color-stop(0.72, #5DBCDA));
  border-radius: 0 0 2px 2px;
}

#action-buttons .answer, #action-buttons .hangup {
  color: #f5f5f5;
  width: 100%;
  font-size: 18px;
  padding: 8px 0;
  text-shadow: 0px -1px 0px rgba(0, 0, 0, 0.4);
  margin: 0;
  background-image: linear-gradient(bottom, #e64118 20%, #E88268 72%);
  background-image: -o-linear-gradient(bottom, #e64118 20%, #E88268 72%);
  background-image: -moz-linear-gradient(bottom, #e64118 20%, #E88268 72%);
  background-image: -webkit-linear-gradient(bottom, #e64118 20%, #E88268 72%);
  background-image: -ms-linear-gradient(bottom, #e64118 20%, #E88268 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #e64118), color-stop(0.72, #E88268));
  border-radius: 0 0 2px 2px;
}

#action-buttons .hold, #action-buttons .unhold, #action-buttons .mute {
  color: #3C1F1F;
  width: 100%;
  font-size: 15px;
  padding: 8px 0;
  text-shadow: 0px 1px 0px rgba(255, 255, 255, 0.3);
  margin: 0;
  background-image: linear-gradient(bottom, #E5C130 20%, #F4F4C2 72%);
  background-image: -o-linear-gradient(bottom, #E5C130 20%, #F4F4C2 72%);
  background-image: -moz-linear-gradient(bottom, #E5C130 20%, #F4F4C2 72%);
  background-image: -webkit-linear-gradient(bottom, #E5C130 20%, #F4F4C2 72%);
  background-image: -ms-linear-gradient(bottom, #E5C130 20%, #F4F4C2 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #E5C130), color-stop(0.72, #F4F4C2));
  /*box-shadow: inset 1px 0px 0px rgba(255, 255, 255, 0.4),
    inset -1px 0px 0px rgba(0, 0, 0, 0.1);*/
}

.save {
  color: #f5f5f5;
  width: 45%;
  font-size: 15px;
  padding: 8px 0;
  text-shadow: 0px -1px 0px rgba(0, 0, 0, 0.3);
  margin: 0;
  background-image: linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -o-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -moz-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -webkit-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -ms-linear-gradient(bottom, #1797c0 20%, #5DBCDA 72%);
  background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.2, #1797c0), color-stop(0.72, #5DBCDA));
  border-radius: 6px 6px 6px 6px;
  border: none;
  margin: 0;
  cursor: pointer;
}

.mute {
  border-radius: 0 0 0 2px;
}

.hold, .unhold {
  border-radius: 0 2px 0 0;
}

#team-status .agents-status, #team-status .queues-status {
  display: inline-block;
  width: 50%;
  margin: 0;
  font-size: 14px;
  text-align: center;
  padding: 12px 0 16px;
  border-bottom: solid 1px #e5e5e5;
}

#team-status [class*="num"] {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 6px;
}

#call-data {
  display: none;
}

.powered-by {
  text-align: right;
  padding: 10px 0;
}

img {
  width: 100px;
}