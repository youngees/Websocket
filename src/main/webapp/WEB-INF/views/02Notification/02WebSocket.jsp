<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">
<script type="text/javascript">
//채팅창 오픈을 위한 함수
function chatWin(skin) {
	//채팅 아이디(대화명)가 입력되었는지 확인한다. 
    var id = document.getElementById("chat_id");
    
    if(id.value==''){
        alert('채팅 닉네임을 입력 후 채팅창을 열어주세요.');
        id.focus();
        return;
    }
    
    //채팅창을 오픈한다.
    var room = document.getElementById("char_room");
    
    if(skin=='normal')
        window.open("02WebChat.do?chat_id="+id.value+"&chat_room="+room.value,
            room.value+"-"+id.value, "width=500, height=700");
    	/*
    	window.open(창의URL(경로), 창의 이름, 창의 속성);
    	※창의 이름이 동일할 경우 여러개의 창을 열어도 하나의 창에서
    	열리게 되므로 항상 다른 이름으로 설정해야 한다.
    	*/
    else 
        window.open("02WebChatUI.do?chat_id="+id.value+"&chat_room="+room.value,
        room.value+"-"+id.value, "width=350, height=490")
}
</script>
</head>
<body>
<div class="container">
	<h2>SPRING WebSocket 활용한채팅</h2>
	<table border="1" cellpadding="10" cellspacing="0">
		<tr>
			<td>채팅방</td>
			<td>
				<select id="char_room">
					<option value="myRoom1">KOSMO-1번방</option>
				</select>
			</td>
		</tr>
		<tr>
			<td>회원아이디</td>
			<td>
				<input type="text" id="chat_id"
					placeholder="본인의 닉네임을 쓰세요."/>
			</td>
		</tr>
		<tr>
			<td colspan="2" style="text-align: center">
				<button type="button" onclick="chatWin('normal');"
					class="btn btn-primary">채팅창열기</button>
				<button type="button" onclick="chatWin('ui');"
					class="btn btn-primary">UI적용된 채팅창열기</button>
			</td>
			
		</tr>
	</table>
</div>
</body>
</html>