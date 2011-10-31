var currentplayer="You";
var playername;
var partofthegame="start";

var mesg=document.getElementById("message");
var humangamespace=document.getElementById("humangs");
var compgamespace=document.getElementById("compgs");

function updateGS(humangs,compgs,message)
{
    humangamespace.innerHTML=humangs;
    compgamespace.innerHTML=compgs;
    mesg.innerHTML=currentplayer+" "+message+"!";
    if (message=="Hello")
    { mesg.innerHTML=message+", "+playername+"!";}
    if (message=="are winner" || message=="is winner")
    { partofthegame="end";
      document.getElementById("retry").style.display="block"; }
}

function switchPlayer()
{ 
    if (currentplayer == "You")
    { currentplayer = "Comp"; }
    else
    { currentplayer = "You"; }
}

function makeTurn(place)
{
    if (partofthegame=="process")
    {
	partofthegame="waiting"
	
	var xmlhttp=new XMLHttpRequest();
	xmlhttp.onreadystatechange=function()
	{
	    if (xmlhttp.readyState==4 && xmlhttp.status==200)
	    {
		partofthegame="process";
	    
		var response=xmlhttp.responseText.split("|");
		var message=response[2];
		updateGS(response[0],response[1],message);
		if (message == "MISSED")
		{
		    if (currentplayer == "Comp")
		    { switchPlayer(); }
		    else
		    { switchPlayer(); makeTurn("none"); }
		}
		else
		{
		    if (currentplayer == "Comp")
		    { makeTurn("none"); }
		}
	    }
	}
	
	if (place == "none")
	{ xmlhttp.open("GET","turn",true); }
	else
	{ xmlhttp.open("GET","turn?place-to-shoot="+place,true); }
	xmlhttp.send();
    }
}

function shoot(event)
{
    if (partofthegame=="process")
    {
	var targ = event.target;
	var x = targ.parentNode.rowIndex + 1;
	var y = targ.cellIndex + 1;
	targ.className="pending";
	makeTurn("("+x+" "+y+")");
    }
}

function readGameSpace ()
{
    var answer="(";
    var x;
    var y;
    for (x=0;x<10;x++)
    {
	var row=humangamespace.getElementsByTagName("tr")[x];
	for (y=0;y<10;y++)
	{
	    var cell=row.getElementsByTagName("td")[y];
	    if (cell.className == "ship")
	    {
		answer = answer + "(" + x + " " + y + ") ";
	    }
	}
    }
    answer = answer + ")";
    return(answer);
}

function getRadioValue (radio)
{
    for (i=0;i<=radio.length;i++)
    {
	if (radio.elements[i].checked==true)
	{ return(radio.elements[i].value); }
    }
}

function createGame (gamespace)
{
    playername=document.getElementById("name").value;
    var enemy=getRadioValue(document.getElementById("enemy"));
    if (playername=="")
    { playername="anonymous"; }

    partofthegame="process";
    mesg.style.display="block";
    mesg.innerHTML="Wait a minute, please.";

    var xmlhttp=new XMLHttpRequest();
    xmlhttp.onreadystatechange=function()
    {
	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
	    var response=xmlhttp.responseText.split("|");
	    updateGS(response[0],response[1],response[2]);
	    
	    document.getElementById("form").style.display="none";
	    document.getElementById("help").style.display="none";
	    compgamespace.style.display="inline";
	}
    }
    xmlhttp.open("GET","create?ships-positions=" + gamespace
		 + "&config=((10 10) (4 3 3 2 2 2 1 1 1 1))"
		 + "&comp-player=" + enemy + "&name=" + playername,true);
    xmlhttp.send();
}

function randomGS ()
{
    mesg.style.display="block";
    mesg.innerHTML="Wait a minute, please.";

    partofthegame="process";

    var xmlhttp=new XMLHttpRequest();
    
    xmlhttp.onreadystatechange=function()
    {
	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
	    humangamespace.innerHTML=xmlhttp.responseText;
	    
	    mesg.style.display="none";
	    mesg.innerHTML="";
	    partofthegame="start";
	}
    }

    xmlhttp.open("GET","random?&config=((10 10) (4 3 3 2 2 2 1 1 1 1))",true);
    xmlhttp.send();
}

function startGame ()
{
    if (partofthegame=="start")
    {
	var gamespace=readGameSpace();
	
	if (gamespace=="()")
	{ return(0); }
	else
	{
	    partofthegame="waiting";
	    var xmlhttp=new XMLHttpRequest();
	    xmlhttp.onreadystatechange=function()
	    {
		if (xmlhttp.readyState==4 && xmlhttp.status==200)
		{
		    if (xmlhttp.responseText=="NIL")
		    { 
			mesg.style.display="block";
			mesg.innerHTML="This position is wrong.";
			partofthegame="start";
		    }
		    else
		    { createGame(gamespace); partofthegame="process" }
		}
	    }

	    xmlhttp.open("GET","correct?&ships-positions="+gamespace,true);
	    xmlhttp.send();
	}
    }
}

function changeClass (event)
{
    if (partofthegame=="start")
    {
	mesg.style.display="none";
	mesg.innerHTML="";
	var t = event.target;
	var n = t.className;
	var gre = function()
	{
	    if (n == "ship")
	    {
		t.className = "";
	    }
	    else
	    {
		t.className = "ship";
	    }
	}
	t.className = "pending";
	var tO = setTimeout(gre,100);
    }
}

function retry()
{
    window.location.reload();
}