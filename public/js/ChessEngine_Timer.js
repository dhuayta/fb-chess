var PopupVisible = false;
var FirsLoad = true;
var GameIsFinish = false;

// Every 5 Seconds check the status
function NetConnect() {
    
    if (GameIsFinish) return;
    
    var objDate = new Date();
    var texto = objDate.getTime();//  + " GameID " + game.gameId;

    var game = jQuery.parseJSON(gameInfo);

    var purl = "getchessstatus?gameId=" + game.gameId;

    $.ajax({ url: purl, cache: false }).done(function (html) { ParseJS(html) });


    //PrintDebug(texto);

    if (FirsLoad) {
        NetConnect_GetBoard();
        FirsLoad = false;
        PlayerCurrentColor = MyUser_GetColor();
    }
}

function NetConnect_GetBoard() {

    var objDate = new Date();
    var texto = objDate.getTime(); //  + " GameID " + game.gameId;

    var game = jQuery.parseJSON(gameInfo);

    var purl = "getchessboard?gameId=" + game.gameId;

    $.ajax({ url: purl, cache: false }).done(function (html) { ParseMoves(html) });


    //PrintDebug(texto);
}

function ParseMoves(html) {

    var resultado = "Inicio";
    //$("#DebugJs").html(resultado);

    if (html == "ERROR") {
        $("#DebugJs").html("Error");
        return;
    }
    var moves = html.split("}");

    resultado = resultado + "Items " + moves.length.toString() + "<br>";


    for (var item in board) {
        
        board[item]="" ;
    }

    for(var x=0;x < moves.length-1; x++)
    {

        var item = jQuery.parseJSON(moves[x] + "}");

        if (item.status == 1) {
            board[item.final] = item.piece;
            resultado = resultado + item.piece + " " + item.final + "<br>";
        }
    }

    RuleClean();

   // $("#DebugJs").html(resultado);

}

function ParseJS(html) {


    var item = jQuery.parseJSON(html);

    // Error Warning
    if (html == "ERROR") {
        $("#DebugJs").html("Error");
        return;
    }


    // Show Board as PlayerCurrentColor = Observador
    if (PlayerCurrentColor == 'Observador')
    {
        // Observador Finish Game
        if (item.status == "Finished")
        {
            ShowMessage("Checkmate!", item.winner + " wins the chess game", "Warning");
            GameIsFinish = true;
            return;
        }

        ShowMessage("Visitor", " This is a realtime game", "success");
        NetConnect_GetBoard();
        return;
    }

   // Setting Global Turns
   CurrentTurnPlayerID = item.currentPlayerId;

   // Fishing Game
    if (item.status == "Finished")
    {
    	if (item.winnerId == PlayerCurrentID)
    	{
    		ShowMessage("Congratulation, you win!", item.winner + " wins the chess game", "success");
    	}
    	else
    	{
    		ShowMessage("Uuh! you lose", item.winner + " wins the chess game", "error");
    		
    	}
    	
    	GameIsFinish = true;
    return;
    }
 
    // Mostrar Warning Turno
    if (item.currentPlayerId == PlayerCurrentID) {

        if (PopupVisible == false) {
            
            ShowMessage("Play!", "  It's your turn, use your best strategy. (" + PlayerCurrentColor + ")", "block");

            PopupVisible = true;
            NetConnect_GetBoard();
        }
    }
    else {

        if (PopupVisible == true) {
            HideMessage();
            PopupVisible = false;
            NetConnect_GetBoard();
        }
    }

}
function NetConnect_SendMove(piece,source, target) {
    var objDate = new Date();
    var texto = objDate.getTime(); //  + " GameID " + game.gameId;

    var game = jQuery.parseJSON(gameInfo);

    var purl = "play?gameId=" + game.gameId + "&piece=" + piece +"&origin=" + source + "&final=" + target;

    //Debug
    //$.ajax({ url: purl, cache: false }).done(function (html) { $("#DebugJs").html("send " + piece); });
    $.ajax({ url: purl, cache: false }).done(function (html) { PrintDebug("send " + piece + " O=" +source + " F=" +target); });
    
}


function PrintStatus(value) {
    $("#DebugText2").val(value);

}

//NetConnect();
window.setInterval(NetConnect, 8000);


function ShowMessage(ptitle, pmessage, ptype)
{
//Warning block
//error   error
//success success
//info    info

	$(".AlertBoxTitle").html(ptitle);
	$(".AlertBoxMessage").html(pmessage);
	
	document.getElementById("AlertBox").className="alert alert-" + ptype;
	
	
	$("#AlertBox").show("slow");
}

 $(document).ready(function() {
  
       NetConnect();
 });

function HideMessage()
{

    $("#AlertBox").hide("slow");

}