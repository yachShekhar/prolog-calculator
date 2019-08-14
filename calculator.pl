:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).

% URL handlers.
:- http_handler(root(.), say_hi, []).
:- http_handler(root(calc), my_handler_code, []).
:- http_handler(root(sum), handle_request, []).

% Calculator root path.
say_hi(_Request) :-
        format('Content-type: text/html~n~n'),
                format('<html>
                   <head>
                      <script>
                         //function that display value
                         var arr = [0, 0]
                         var isLhs = true;
                         var operator;
                         function dis(val) {
                           document.getElementById(\"result\").value += val;
                           if(isLhs && typeof val === \"number\"){
                              arr[0] = arr[0] * 10 + val;
                            } else if("+-*/".includes(val)) {
                              if(isLhs){
                                isLhs = false;
                              } else {
                                solve(val);
                              }
                              operator = val;
                            }else{
                              arr[1] = arr[1] * 10 + val;
                            }
                         }

                         //function that evaluates the digit and return result
                         function solve(val) {
                           if(!val){
                             isLhs = true;
                           }
                           let ops = operator;
                           var action = getAction(operator);
                           var data = JSON.stringify({\"a\": arr[0], \"b\": arr[1], \"c\": action});
                           var xhr = new XMLHttpRequest();
                           xhr.withCredentials = true;
                           xhr.addEventListener(\"readystatechange\", function () {
                              if (this.readyState === 4) {
                                console.log(this.responseText);
                                var resp = JSON.parse(this.responseText);
                                var node = document.createElement(\"LI\");
                                var textnode = document.createTextNode(arr[0] + \" \" + ops + \" \" + arr[1] + \" = \" +resp.answer);
                                node.appendChild(textnode);
                                var el = document.getElementById(\"history\");
                                el.insertBefore(node, el.childNodes[0] || null);
                                arr[0] = resp.answer;
                                document.getElementById(\"result\").value = arr[0] + (val === undefined ? "" : operator) ;
                                arr[1] = 0;
                              }
                            });
                            xhr.open(\"POST\", \"http://localhost:8000/calc");
                            xhr.setRequestHeader(\"Content-Type\", \"application/json\");
                            xhr.send(data);
                         }

                        //function to return action by symbol
                        function getAction(symbol){
                          switch(symbol){
                           case "+":
                             return \"addition\";
                           case "-":
                             return \"subtraction\";
                           case \"/\":
                             return \"division\";
                           case \"*\":
                             return \"multiplication\";
                          }
                        }

                         //function that clear the display
                         function clr() {
                             document.getElementById(\"result\").value = \"\"
                             arr[0] = 0; arr[1] = 0;
                             isLhs = true;
                         }
                      </script>
                      <style>
                         input[type=\"button\"]
                         {
                         background-color:yellow;
                         color: black;
                         border: solid black 2px;
                         width:100%
                         }

                         input[type=\"text\"]
                         {
                         background-color:white;
                         border: solid black 2px;
                         width:100%
                         }
                         .title{
                         margin-bottom: 10px;
                         text-align:center;
                         width: 210px;
                         color:black;
                         border: solid black 2px;
                         }
                      </style>
                   </head>
                   <body>
                      <div class = title >Prolog Calculator</div>
                      <table border=\"1\">
                         <tr>
                            <td colspan=\"3\"><input type=\"text\" id=\"result\"/></td>
                            <td><input type=\"button\" value=\"c\" onclick=\"clr()\"/> </td>
                         </tr>
                         <tr>
                            <td><input type=\"button\" value=\"1\" onclick=\"dis(1)\"/> </td>
                            <td><input type=\"button\" value=\"2\" onclick=\"dis(2)\"/> </td>
                            <td><input type=\"button\" value=\"3\" onclick=\"dis(3)\"/> </td>
                            <td><input type=\"button\" value=\"/\" onclick=\"dis(\'/\')\"/> </td>
                         </tr>
                         <tr>
                            <td><input type=\"button\" value=\"4\" onclick=\"dis(4)\"/> </td>
                            <td><input type=\"button\" value=\"5\" onclick=\"dis(5)\"/> </td>
                            <td><input type=\"button\" value=\"6\" onclick=\"dis(6)\"/> </td>
                            <td><input type=\"button\" value=\"-\" onclick=\"dis(\'-\')\"/> </td>
                         </tr>
                         <tr>
                            <td><input type=\"button\" value=\"7\" onclick=\"dis(7)\"/> </td>
                            <td><input type=\"button\" value=\"8\" onclick=\"dis(8)\"/> </td>
                            <td><input type=\"button\" value=\"9\" onclick=\"dis(9)\"/> </td>
                            <td><input type=\"button\" value=\"+\" onclick=\"dis(\'+\')\"/> </td>
                         </tr>
                         <tr>
                            <td><input type=\"button\" value=\".\" onclick=\"dis(\'.\')\"/> </td>
                            <td><input type=\"button\" value=\"0\" onclick=\"dis(0)\"/> </td>
                            <td><input type=\"button\" value=\"=\" onclick=\"solve()\"/> </td>
                            <td><input type=\"button\" value=\"*\" onclick=\"dis(\'*\')\"/> </td>
                         </tr>
                      </table>
                      <div>
                        <ul id=\"history\">
                        </ul>
                      </div>
                   </body>
                </html> ~n').


% Calculates a and b based upon c.
solve(_{a:X, b:Y, c:O}, _{answer:N}) :-
  (O="squareRoot"->N is sqrt(X);
  O="addition"->N is X+Y;
  O="subtraction"->N is X-Y;
  O="multiplication"->N is X*Y;
  O="division"->N is X/Y;
  O="mod"->N is mod(X,Y)).

my_handler_code(Request) :-
  http_read_json_dict(Request, Query),
  solve(Query, Solution),
  reply_json_dict(Solution).

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

:- initialization(server(8000)).
