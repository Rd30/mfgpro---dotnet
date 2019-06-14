<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Parents.aspx.cs" Inherits="MFGPRO_dotnet.Parents" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloHead.html" -->
    <!-- Bootstrap Table -->
    <!--<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.10.1/bootstrap-table.min.js"></script>-->
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://unpkg.com/bootstrap-table@1.13.5/dist/bootstrap-table.min.css">
    <!-- Latest compiled and minified JavaScript -->
    <script src="https://unpkg.com/bootstrap-table@1.13.5/dist/bootstrap-table.min.js"></script>
    <!-- Latest compiled and minified Locales -->
    <script src="https://unpkg.com/bootstrap-table@1.13.5/dist/locale/bootstrap-table-zh-CN.min.js"></script>
</head>
<body>
    <div class="loading"></div> <!-- Page loading -->
    <!-- Dark overlay element -->
	<div class="overlay" id="overlay"></div>

	<!--NavBar/Header-->
	<div class="all-gp-sloHeader" id="itemHeader"><!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloHeader.html" --></div>
    
    <!--SideBar-->
	<!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloSidebar.html" -->

    <div id="parents-qry-str">
        <input id="item-hid" type="hidden" value="<%=Request.QueryString["item"]%>"/>
        <input id="item-no" type="hidden"/>
        <input id="rev-no" type="hidden"/>
        <input id="drawing-no" type="hidden"/>
    </div>
    <br/>
    <div id="parents-out" class="manuAlign container">
        <h5 class="srchResTable">
            Parents of <a href="Item.aspx?item=<%=Request.QueryString["item"]%>"><%=Request.QueryString["item"]%></a> 
            <small>
                <span id="desc1"></span><span id="desc2"></span>
                [<span id="view-draw"></span>
                   <span id="level"><a href="Parents.aspx?item=<%=Request.QueryString["item"]%>&level=all">All Parents </a>
                       <a style="display:none" href="Parents.aspx?item=<%=Request.QueryString["item"]%>">1 Level Parents</a></span>]
            </small>
        </h5>        
    </div>

    <br/>

    <div id="parent-items" class="container srchResTable">            
       <ul class="list-group"></ul>
    </div>

    <script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>    
	<script type="text/javascript">
        'use strict';
        $(document).ready(function () {

            var psSpinner = $('.loading');
            psSpinner.show();   // Display loading until AJAX success.

            $('#pageTitleDiv').html("");
            $('#pageTitleDiv').html("<h5>MFGPRO</h5>");
            $('#shortPageTitleDiv').html("");
            $('#shortPageTitleDiv').html("<h5>MFGPRO</h5>");

            var itemVal = $("#item-hid").val();  // Fetch the item.
            var item, revision, drawing; 

            // AJAX call to get the part(or, the item) details.
            $.ajax({
                type: "GET",
                dataType: "JSON",
                contentType: "application/JSON; charset=utf-8",
                data: { item: itemVal, desc:'' },
                url: "http://localhost:51059/api/Mfgpro/SearchResults",
                success: function (data) {
                    var parsedData = JSON.parse(data);

                    $.each(parsedData, function (i, data) {
                        item = data.pt_part;
                        revision = data.pt_rev;

                        data.pt_draw = (data.pt_draw).trim();
                        data.pt_draw = (data.pt_draw).toUpperCase();
                        drawing = data.pt_draw;

                        $("#desc1").append(data.pt_desc1);
                        $("#desc2").append(data.pt_desc2);
                    });

                    if ((drawing == "NONE") || (drawing == "")) {       //Check if drawing == "NONE".
                        console.log("There is no drawing for the part :"+item);                       
                    } else {
                        let retDraw = getDrawPath(item, revision, drawing);                          
                        $("#view-draw").append(retDraw); // Sets the "View Drawing" if drawing exists.
                    }

                    getParents(item);  // get the parents of an item/part/component.              
                   
                },
                error: function (xhr, errorType, exception) {
                    console.log("Error : " + xhr.responseText);
                    $(".alert").attr("hidden", false);
                    $(".alert").text("Error ! Please contact IT");
                },
                failure: function (response) {
                    console.log("Failure : " + response.responseText);
                    $(".alert").attr("hidden", false);
                    $(".alert").text("Failure ! Please contact IT");
                }
            });

            var urlParams = new URLSearchParams(window.location.search); // get the query string parameter. 

            // Function to get the children parts/items/components.
            function getParents(item) {
                var drawing;

                $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    async: false, //asynchronous to fetch and append the parent parts/components recursively.
                    data: { item: item },
                    url: "http://localhost:51059/api/Mfgpro/GetParents",
                    success: function (data) {
                        var parsedParentsData = JSON.parse(data);

                        $.each(parsedParentsData, function (i, data) {

                            data.pt_draw = (data.pt_draw).trim();
                            data.pt_draw = (data.pt_draw).toUpperCase();

                            if ((data.pt_draw !== 'NONE') && (data.pt_draw !== "")) {
                                drawing = getDrawPath(data.ps_par, data.pt_rev, data.pt_draw);
                            }
                            else {
                                drawing = "";
                            }
                                                        
                            if ($("#parent-items ul li:contains(" + data.ps_comp + ")").length > 0) {

                                let parent = $("#parent-items ul li:contains(" + data.ps_comp + ")").parent();
                                    
                                parent.append('<ol><li style="list-style-type:none"><a href=http://localhost:51059/Item.aspx?item=' + data.ps_par + '>' + data.ps_par + '</a> ' +
                                   '(' + data.ps_qty_per + ' ' + data.pt_um + ') ' + data.pt_desc1 + '  ' + data.pt_desc2 + ' [ ' + drawing +
                                   '<a href=http://localhost:51059/Parents.aspx?item=' + data.ps_par + '>Parents</a> |' +
                                   '<a href=http://localhost:51059/ProdStruct.aspx?item=' + data.ps_par + '>PS</a> ]</li></ol>');

                            } else {

                                $("#parent-items ul").append("<li><a href=http://localhost:51059/Item.aspx?item=" + data.ps_par + ">" + data.ps_par + "</a> " +
                                    "(" + data.ps_qty_per + " " + data.pt_um + ") " + data.pt_desc1 + "  " + data.pt_desc2 + " [ " + drawing +
                                    "<a href=http://localhost:51059/Parents.aspx?item=" + data.ps_par + ">Parents</a> |" +
                                    "<a href=http://localhost:51059/ProdStruct.aspx?item=" + data.ps_par + ">PS</a> ]</li>");

                            }

                            if (urlParams.has('level')) { 
                                getParents(data.ps_par); // recursively get the parent items.
                            }

                        });

                        $('.loading').attr("hidden", true); // Hide the loading icon/screen                   
                        
                    },                 
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                        $(".alert").attr("hidden", false);
                        $(".alert").text("Error ! Please contact IT");
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                        $(".alert").attr("hidden", false);
                        $(".alert").text("Failure ! Please contact IT");
                    }
                });
            }            

            function getDrawPath(item, revision, drawing) {  
                var retDrawPath = "";

                $.ajax({
                    type: "POST",
                    async: false,  // asynchronous to false. 
                    url: "ProdStruct.aspx/GetDrawingPath", // try, App_Code/MfgproUtils.cs/GetDrawingPath
                    dataType: "json",                    
                    data: JSON.stringify({ item: item, revision: revision, drawing: drawing }),
                    contentType: "application/JSON; charset=utf-8",
                    success: function (data) {
                        if (data.d !== "") {                                                       
                            retDrawPath = "<a href=http://nd-wind.entegris.com/Department/doc_con/DWG/REL/" + data.d + ">View Drawing</a> | ";                            
                        }                        
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                    }
                });                
               return retDrawPath;
            }

            if (urlParams.has('level')) {                 
                $('#level a:nth-child(1)').css('display', 'none');
                $('#level a:nth-child(2)').show();
            }

        });
    </script>

</body>
</html>
