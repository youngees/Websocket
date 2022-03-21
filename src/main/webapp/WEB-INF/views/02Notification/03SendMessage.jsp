<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head> 
<meta charset="UTF-8">
<title>Title</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<script>

var messageWindow;  //대화내용이 출력될 엘리먼트
var inputMessage;   //대화 입력 상자
var chat_id;        //클라이언트의 아이디 
var webSocket;      //웹소켓 객체
var logWindow;      //대화창 아래에 로그를 출력할 엘리먼트 

//해당 문서의 로드가 완료되었을때 
window.onload = function() {
   //전역변수로 선언한 엘리먼트의 DOM객체를 얻어와서 저장
    messageWindow = document.getElementById("messageWindow");
    inputMessage = document.getElementById("inputMessage");
    chat_id = document.getElementById("chat_id").value; //클라이언트의 아이디 
    logWindow = document.getElementById('logWindow');
   
    //messageWindow.scrollTop = messageWindow.scrollHeight;
    
    //웹소켓 객체 생성(웹소켓 서버에서 @EndPoint로 선언된 요청명을 통해 생성한다.)
    webSocket = new WebSocket('ws://192.168.219.101:8081/websocket/EchoServer.do');
    //webSocket = new WebSocket('ws://localhost:8081/websocket/EchoServer.do');

    //클라이언트가 접속했을때 
    webSocket.onopen = function(event) {
        wsOpen(event);
    };
    //서버가 클라이언트에게 메세지를 보냈을때 
    webSocket.onmessage = function(event) {
        wsMessage(event);
    };
    //클라이언트가 접속을 종료했을때 
    webSocket.onclose = function(event) {
        wsClose(event);
    };
    //채팅중 에러가 발생했을때 각 함수를 호출한다. 
    webSocket.onerror = function(event) {
        wsError(event);
    };
}

//접속했을때 호출됨
function wsOpen(event) {
    writeResponse("연결성공");
}

//서버가 클라이언트에게 메세지를 보냈을때 호출됨
function wsMessage(event) {
    var message = event.data.split("|");
    var sender = message[0];
    var content = "temp";
    content = message[1];//메세지
   
    writeResponse(event.data); //로그창에 출력

    if(content == "") {
      //전송된 내용이 없다면 아무것도 하지 않는다.
    }
    else {
       //대화내용에 /가 포함되어 있다면 명령어로 판단한다. 
        if(content.match("/")) {
            //귓속말
            if(content.match(("/" + chat_id))) {
            console.log("notify()");
            //노티함수 호출
            notify(content);
            }
        }
        else {
        }
    }
}
//접속이 종료되었을때 호출
function wsClose(event) {
    writeResponse("대화종료");
}

//에러 발생시 호출
function wsError(event) {
    writeResponse("에러발생");
    writeResponse(event.data);
}

//웹소켓으로 메세지를 보냄
function sendMessage() {
      //메세지를 귓속말을 보내듯이 조립한다. => /닉네임 메세지내용 
      receive_id = $("#receive_id").val();
      inputMessage = '/'+receive_id+' '+$("#inputMessage").val();
   
      //메세지 조립 및 전송
      var send_message = chat_id+'|'+inputMessage;
      console.log('send_message:'+send_message);
    webSocket.send(send_message);
}

function enterkey() {    
   if (window.event.keyCode==13) {
       sendMessage();
   }
}
function writeResponse(text){
    //logWindow.innerHTML += "<br/>"+text;
    console.log(text);
}
function notify(notiMsg) {
   if (Notification.permission !== 'granted') {
       alert('notification is disabled');
   }
   else {
       var notification = new Notification(
          notiMsg,
          {
               icon: 'https://t4.ftcdn.net/jpg/00/78/87/93/500_F_78879336_2f2Ivwq2jN2EFMSJSi72OevDAQob2JJv.jpg',
               body: '쪽지가 왔습니다.',
           }
       );
       //Noti에 핸들러를 사용한다.
       notification.onclick = function () {
           alert('링크를 이용해서 해당페이지로 이동할 수 있다.');
       };
   }       
   //토스트로 표시
   $('.toast-body').html(notiMsg);
    $('.toast').toast({delay: 5000}).toast('show');
}
</script>
</head>
<body>
<div class="container">
    <table class="table table-bordered">
       <tr>
          <td>방명:</td>
          <td><input type="text" id="chat_room" class="form-control" value="${sessionScope.chat_room }" /></td>
       </tr>
       <tr>
          <td>닉네임:</td>
          <td><input type="text" id="chat_id" class="form-control" value="${sessionScope.chat_id }" /></td>
       </tr>
       <tr>
          <td>받는사람아이디:</td>
          <td><input type="text" id="receive_id" class="form-control" value="" placeholder="받는사람 아이디를 입력하세요" /></td>
       </tr>
       <tr>
          <td>쪽지내용:</td>
          <td>
             <input type="text" id="inputMessage" class="form-control float-left mr-1" style="width:70%"
             onkeyup="enterkey();" />
             <input type="button" value="쪽지전송" onclick="sendMessage();" class="btn btn-info float-left" />
          </td>
       </tr>
    </table>

    <script>
    $(document).ready(function() {
       //토스트 테스트
       $('#myBtn').click(function(){
          $('.toast').toast({delay: 2000});
          $('.toast').toast('show');
       });
    });
    </script>
    <button type="button" class="btn btn-primary" id="myBtn">Show Toast</button>
    <div class="toast mt-3">
       <div class="toast-header">
          쪽지가 왔습니다.(5초후 닫힙니다.)
       </div>
       <div class="toast-body">
          쪽지내용
       </div>
    </div>  
</div>
</body>
</html>