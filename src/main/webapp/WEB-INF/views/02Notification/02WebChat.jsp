<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head> 
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">
<script>
//채팅에서 사용할 전역변수 생성 
var messageWindow; //대화내용이 출력될 엘리먼트
var inputMessage;  //대화 입력 상자
var chat_id;	   //클라이언트의 아이디 
var webSocket;	   //웹소켓 객체
var logWindow;	   //대화창 아래에 로그를 출력할 엘리먼트 

//해당 문서의 로드가 완료되었을때 
window.onload = function() {
	//전역변수로 선언한 엘리먼트의 DOM객체를 얻어와서 저장
    messageWindow = document.getElementById("messageWindow");
    inputMessage = document.getElementById("inputMessage");
    chat_id = document.getElementById("chat_id").value; //클라이언트의 아이디 
    logWindow = document.getElementById('logWindow');
	
    //스크롤바를 항상 아래로 내려주는 역할을 한다.
    messageWindow.scrollTop = messageWindow.scrollHeight;
    
    //웹소켓 객체 생성(웹소켓 서버에서 @EndPoint로 선언된 요청명을 통해 생성한다.)
    //webSocket = new WebSocket('ws://192.168.219.101:8081/websocket/EchoServer.do');
    webSocket = new WebSocket('ws://localhost:8081/websocket/EchoServer.do');

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
	/*
	메세지를 |(파이프) 기호로 분리하여 앞부분은 보낸사람, 뒷부분은 메세지로
	각각 변수에 저장한다. 
	*/
    var message = event.data.split("|");
    var sender = message[0];
    var content = message[1];
    var msg;
	
    writeResponse(event.data); //로그창에 출력

    if(content == "") {
		//전송된 내용이 없다면 아무것도 하지 않는다.
    }
    else {
    	//대화내용에 /가 포함되어 있다면 명령어로 판단한다. 
        if(content.match("/")) {
        	/*
        	현재 접속한 클라이언트의 아이디를 이용해서 본인한테 온 귓속말인지
        	판단한다. 아래 chat_id는 현재 페이지 로드시 접속한 아이디를 통해
        	전역변수에 저장되어 있는 값이다. 
        	따라서 받는사람이 본인인 경우에만 대화내용을 디스플레이한다. 
        	*/
            if(content.match(("/" + chat_id))) {
            	//명령어 부분을 '귓속말'로 변경한다. 
                var temp = content.replace(("/"+chat_id), "[귓속말]");
            	//메세지에 UI(디자인)을 적용하는 부분
                msg = makeBalloon(sender, temp);
            	//대화창에 대화내용을 출력한다. 
                messageWindow.innerHTML += msg;
            	//대화창의 스크롤바를 항상 아래로 내려준다. 
                messageWindow.scrollTop = messageWindow.scrollHeight;
            }
        }
        else {
        	//대화내용에 /가 없다면 일반적인 메세지로 판단한다. 
            msg = makeBalloon(sender, content);
        	/*일반적인 대화내용은 모든 클라이언트에게 디스플레이 되므로 
        	대화창에 즉시 출력한다.*/
            messageWindow.innerHTML += msg;
            messageWindow.scrollTop = messageWindow.scrollHeight;
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

//메세지를 출력하기전 UI를 적용하는 함수 
function makeBalloon(id, cont) {
    var msg = '';
    msg += '<div>'+id+':'+cont+'</div>';
    return msg;
}

//클라이언트가 입력한 대화내용을 서버로 전송한다. 
function sendMessage() {
	//웹소켓 서버로 전송시 파이프 기호를 통해 아이디와 내용을 구분한다. 
    webSocket.send(chat_id+'|'+inputMessage.value);

	//내가 보낸 대화내용을 대화창에 디스플레이 한다. 
	//(서버로 메세지를 보내면 나를 제외한 모든 클라이언트에게 메세지를 전송한다.)
    var msg = '';
    msg += '<div style="text-align:right;">'+inputMessage.value+'</div>';
    messageWindow.innerHTML += msg;
    inputMessage.value = ""; //대화입력창을 비운다.
    messageWindow.scrollTop = messageWindow.scrollHeight; //스크롤바를 아래로 내린다. 
}

//대화내용을 입력한 후 Enter키를 통해 메세지를 전송할 수 있다.
function enterkey() {
	//키보드를 눌렀다가 뗐을때 키코드값이 13일때만 전송 함수를 호출한다.
    if(window.event.keyCode==13) {
    	sendMessage();
    }
}

//대화창 아래의 로그창에 채팅 내역을 보여준다. 
function writeResponse(text) {
	logWindow.innerHTML += "<br/>"+text;
	logWindow.scrollTop = logWindow.scrollHeight;
}
</script>
</head>
<body>
<div class="container">
    <input type="hidden" id="chat_id" value="${param.chat_id }" />
    <input type="hidden" id="chat_room" value="${param.chat_room }" />
    <table class="table table-bordered">
	   	 <tr>
	   		 <td>방명:</td>
	   		 <td>${param.chat_room }</td>
	   	 </tr>
	   	 <tr>
	   		 <td>닉네임:</td>
	   		 <td>${param.chat_id }</td>
	   	 </tr>
	   	 <tr>
	   		 <td>메시지:</td>
	   		 <td>
	   			 <input type="text" id="inputMessage" class="form-control float-left mr-1" style="width:75%"
	   			 onkeyup="enterkey();" />
	   			 <input type="button" id="sendBtn" onclick="sendMessage();" value="전송" class="btn btn-info float-left" />
	   		 </td>
	   	 </tr>
    </table>
    <div id="messageWindow" class="border border-primary" style="height:300px; overflow:auto;">
   	 <div style="text-align:right;">내가쓴거</div>
   	 <div>상대가보낸거</div>
    </div>   
	<div id="logWindow" class="border border-danger" style="height:130px; overflow:auto;"></div>   

</div>
</body>
</html>