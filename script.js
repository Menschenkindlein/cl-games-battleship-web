var currentplayer="You";
var playername;

function updateGS(humangs,compgs,message)
{
    document.getElementById("humangs").innerHTML=humangs;
    document.getElementById("compgs").innerHTML=compgs;
    document.getElementById("message").innerHTML=currentplayer+" "+message+"!";
    if (message=="Hello")
    { document.getElementById("message").innerHTML=message+", "+playername+"!";}
    if (message=="are winner" || message=="is winner")
    { document.getElementById("retry").style.display="inline"; }
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
    var xmlhttp=new XMLHttpRequest();
    xmlhttp.onreadystatechange=function()
    {
	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
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
    if (place === "none")
    { xmlhttp.open("GET","turn",true); }
    else
    { xmlhttp.open("GET","turn?place-to-shoot="+place,true); }
    xmlhttp.send();
}

function shoot(event)
{
    var targ = event.target;
    var x = targ.parentNode.rowIndex + 1;
    var y = targ.cellIndex + 1;
    targ.className="pending";
    makeTurn("("+x+" "+y+")");
}

function readGameSpace ()
{
    var gamespace=document.getElementById("humangs");
    var answer="(";
    var x;
    var y;
    for (x=0;x<10;x++)
    {
	var row=gamespace.getElementsByTagName("tr")[x];
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

function createGame ()
{
    var gamespace=readGameSpace();
    playername=document.getElementById("name").value;
    if (playername=="")
    { playername="anonymous"; }

    var xmlhttp=new XMLHttpRequest();
    xmlhttp.onreadystatechange=function()
    {
	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
	    var response=xmlhttp.responseText.split("|");
	    updateGS(response[0],response[1],response[2]);
	    document.getElementById("form").style.display="none";
	    document.getElementById("help").style.display="none";
	    document.getElementById("compgs").style.display="inline";
	    document.getElementById("message").style.display="inline";
	}
    }
    xmlhttp.open("GET","create?ships-positions=" + gamespace
		 + "&config=((10 10) (4 3 3 2 2 2 1 1 1 1))"
		 + "&comp-player=hard" + "&name=" + playername,true);
    xmlhttp.send();
}

function randomGS ()
{
    var xmlhttp=new XMLHttpRequest();
    xmlhttp.onreadystatechange=function()
    {
	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
	    document.getElementById("humangs").innerHTML=xmlhttp.responseText;
	}
    }
    xmlhttp.open("GET","random?&config=((10 10) (4 3 3 2 2 2 1 1 1 1))",true);
    xmlhttp.send();
}

function showHide()
{
    var gs=document.getElementById("humangs");
    if (gs.style.display=="none")
    { gs.style.display="inline"; }
    else
    { gs.style.display="none"; }
}

function changeClass (event)
{
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

function retry()
{
    window.location.reload();
}