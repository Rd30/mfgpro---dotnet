<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProdStruct.aspx.cs" Inherits="MFGPRO.ProdStruct" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloHead.html" -->
</head>
<body>
    <div class="loading"></div> <!-- Page loading -->
    <!-- Dark overlay element -->
	<div class="overlay" id="overlay"></div>

	<!--NavBar/Header-->
	<div class="all-gp-sloHeader" id="itemHeader"><!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloHeader.html" --></div>
    
    <!--SideBar-->
	<!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloSidebar.html" -->

    <div id="qry-str">
        <input id="item-hid" type="hidden" value="<%=Request.QueryString["item"]%>"/>
        <input id="item-no" type="hidden"/>
        <input id="rev-no" type="hidden"/>
        <input id="drawing-no" type="hidden"/>
    </div>    
    
    <div class="container">
        <div class="alert alert-danger text-center" role="alert" hidden></div>   
    </div>

    <br/>

    <div id="prodstruct-out" class="container">        
        <h5><span id="level-label">Single Level</span> Product Structure for <%=Request.QueryString["item"]%></h5>
        <br/>
        <h5 class="srchResTable"><a href="Item.aspx?item=<%=Request.QueryString["item"]%>"><%=Request.QueryString["item"]%></a>, 
            Rev <span id="rev"></span>, <span id="desc1"></span><span id="desc2"></span>
            <small>[ <span id="view-draw"></span> <span id="parents"><a href="Parents.aspx?item=<%=Request.QueryString["item"]%>">Parents</a></span> 
                | <span id="level"><a href="ProdStruct.aspx?item=<%=Request.QueryString["item"]%>&c=y">All Levels </a><a style="display:none" href="ProdStruct.aspx?item=<%=Request.QueryString["item"]%>">Single Level </a></span>]</small></h5>
    </div>

    <br/>

    <div id="pend-ecn" class="container pend-ecn">         
         <h6>Pending ECNs:</h6>           
         <div id="parent-ecn">
            <table id="parent-ecn-tbl" class="table-sm srchResTable">
                <thead>
                    <tr>                            
                        <th>ECR/N</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Problem</th>                            
                    </tr>
                </thead>
                <tbody></tbody>
            </table>    
         </div>
         <div id="child-ecn">
             <span><strong><button type="button" class="btn btn-secondary" id="rollup-btn">-</button> <span id="num-children"></span> Sub Assembly ECN(s)</strong></span>
             <div id="children-rollup-container" class="container-fluid">
                <table id="child-ecn-tbl" class="table-sm container-fluid srchResTable">
                    <thead>
                        <tr>
                            <th>Part</th>
                            <th>ECR/N</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Problem</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>                 
             </div>
         </div>
        <br/>
    </div>

    <br/>

    <div id="child-items" class="container srchResTable">
       <div class="alert alert-danger text-center" id="no-child-alert" role="alert" hidden></div>
       <ul class="list-group"></ul>
    </div>

    <script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>    
	<script type="text/javascript">
        'use strict';
        $(document).ready(function () {
            
            var urlParams = new URLSearchParams(window.location.search); // get the query string parameter.        

            var psSpinner = $('.loading');	
			    psSpinner.show();   // Display loading until AJAX success.

            $('#pageTitleDiv').html("");
            $('#pageTitleDiv').html("<h5>MFGPRO</h5>");
            $('#shortPageTitleDiv').html("");
            $('#shortPageTitleDiv').html("<h5>MFGPRO</h5>");               

            var itemVal = $("#item-hid").val();  // Fetch the item.         

            var item, revision, drawing, modEcnPart;            

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

                        $("#rev").append(data.pt_rev);
                        $("#desc1").append(data.pt_desc1);
                        $("#desc2").append(data.pt_desc2);
                    });

                    if ((drawing == "NONE") || (drawing == "")) {       //Check if drawing == "NONE".
                        console.log("There is no drawing for the part :"+item);                       
                    } else {                        
                        let retDraw = getDrawPath(item, revision, drawing);                          
                        $("#view-draw").append(retDraw); // Sets the "View Drawing" if drawing exists.
                    }

                    let regEx = new RegExp("^M()-(\d\d)?\d$", "g");
                    let ecnPart = item.replace(regEx, "");

                    modEcnPart = convertPartNum(ecnPart);
                    
                    getEcnXml(); // get all the ECNs on page load. 

                    getChildren(item); // Get child items(or, components) of a part.
                    
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

            // Fetch the ECNs from nd-backdraft
            function getEcnXml() {           
                $.ajax({
                    type: "GET",                    
                    url: "http://localhost:51059/api/Mfgpro/GetEcnXml",
                    contentType: "application/JSON; charset=utf-8",                    
                    dataType: "JSON",                   
                    success: function (data) {
                        let parsedData = JSON.parse(data);                  

                        parseEcn(item, parsedData, false, "", "");   // Parse ECNs function call.                                  
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                    }
                });
            }
            
               
            // Function to return the drawing path of a part.
            function getDrawPath(item, revision, drawing) {  
                var retDrawPath = "";

                $.ajax({
                    type: "POST",
                    async: false,  // asynchronous to false. 
                    url: "ProdStruct.aspx/GetDrawingPath",
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

            var ecnCount = 0;
            // Parse the ECNs if present for a Parent(main component) and for the Children components(Sub-Components or Sub-Assembly)  
            function parseEcn(parent, dir, isChild, revision, draw) {
                
                var modParent = convertPartNum(parent);                
                            
                for (var entry in dir) {

                    // ECN for the Parent itself.
                    if ((entry == modParent) && !(isChild)) {
                        let parTemp = dir[entry];
                        parTemp = parTemp.replace('<td><a href="', '<td><a href="http://nd-backdraft.entegris.com');
                        $("#parent-ecn-tbl tbody").append(parTemp);                                              
                    }

                    // ECN for the Child(Sub Assembly ECNs).
                    if ((entry == modParent) && (isChild)) {
                                              
                       let temp = dir[entry];  //assign the dir[entry] to temp variable instead of replacing the original dir[entry].

                        temp = temp.replace('<td><a href="', '<td><a href=http://localhost:51059/Item.aspx?item=' + parent + '>' + parent + '<a></td><td><a href="http://nd-backdraft.entegris.com');

                        if ((draw !== "") && (draw !== 'NONE') && (draw !== "none")) {
                            draw = getDrawPath(parent, revision, draw);     //fetch the drawing path part(or the sub component)
                            temp = temp.replace("</tr>", "<td><small>[ " + draw + " <a href=http://localhost:51059/Parents.aspx?item="
                                        + parent + ">Parents</a> | <a href=http://localhost:51059/Prodstruct.aspx?item=" + parent + ">PS</a> ] </small></td></tr>");
                        } else {
                            temp = temp.replace("</tr>", "<td><small>[ <a href=http://localhost:51059/Parents.aspx?item="
                                        + parent + ">Parents</a> | <a href=http://localhost:51059/Prodstruct.aspx?item=" + parent + ">PS</a> ] </small></td></tr>");
                        }

                        $("#child-ecn-tbl tbody").append(temp);

                        $("#num-children").text(++ecnCount); // Number of Sub Assembly ECNs.
                    }                    
                }
                               
                $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    data: { item: parent },
                    url: "http://localhost:51059/api/Mfgpro/GetChildren",
                    success: function (data) {
                        var parsed = JSON.parse(data);

                        $.each(parsed, function (i, data) {
                            data.pt_draw = (data.pt_draw).trim();
                            data.pt_draw = (data.pt_draw).toUpperCase();

                            parseEcn(data.ps_comp, dir, true, data.pt_rev, data.pt_draw);
                        });

                        // Hide the Children ECN table if there are no elements in it.
                        if ($("#child-ecn-tbl tbody tr").length <= 0) {
                            $("#child-ecn").attr('hidden', true);
                        } else {
                             $("#child-ecn").attr('hidden', false);
                        }

                        // Hide the Parent ECN table if there are no elements in it.
                        if ($("#parent-ecn-tbl tbody tr").length <= 0) {
                            $("#parent-ecn").attr('hidden', true);
                        } else {
                            $("#parent-ecn").attr('hidden', false);
                        }
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                    }
                });                            
            }

            // Function to get the children parts/items/components.
            function getChildren(item) {
               var modpart, phantom, phantomText, drawing;           
               
               $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    async: false, //asynchronous to fetch and append the child parts/components recursively.
                    data: { item: item },
                    url: "http://localhost:51059/api/Mfgpro/GetChildren",
                    success: function (data) {                    
                        var parsedChildrenData = JSON.parse(data);
                        
                        $.each(parsedChildrenData, function (i, data) {                                
                            modpart = convertPartNum(data.ps_comp);

                            data.pt_draw = (data.pt_draw).trim();
                            data.pt_draw = (data.pt_draw).toUpperCase();

                            if ((data.pt_draw !== 'NONE') && (data.pt_draw !== "")) {
                                drawing = getDrawPath(data.ps_comp, data.pt_rev, data.pt_draw);
                            }
                            else {
                                drawing = "";
                            }

                            if ((data.pt_phantom) || ((data.ps_ps_code).toUpperCase() == "X")) {
                                phantom = "phantom";
                                phantomText = "PHANTOM"
                            }
                            else {
                                phantom = "";
                                phantomText = "";
                            }

                            if (data.ps_item_no == 0) {                                                                

                                if ($("#child-items ul li:contains(" + data.ps_par + ")").length > 0) {
                                    let parent = $("#child-items ul li:contains(" + data.ps_par + ")").parent();
                                                                     
                                    parent.append('<ol><li style="list-style-type:none" class='+phantom+'>' + phantomText + ' <a href=http://localhost:51059/Item.aspx?item=' + data.ps_comp + '>' + data.ps_comp + '</a> ' +
                                        '(' + data.ps_qty_per + ' ' + data.pt_um + ') ' + data.pt_desc1 + '  ' + data.pt_desc2 + ' [ ' + drawing +
                                        '<a href=http://localhost:51059/Parents.aspx?item=' + data.ps_comp + '>Parents</a> |' +
                                        '<a href=http://localhost:51059/ProdStruct.aspx?item=' + data.ps_comp + '>PS</a> ]</li></ol>');
                                } else {
                                    $("#child-items ul").append('<li class='+phantom+'>' + phantomText + ' <a href=http://localhost:51059/Item.aspx?item=' + data.ps_comp + '>' + data.ps_comp + '</a> ' +
                                    '(' + data.ps_qty_per + ' ' + data.pt_um + ') ' + data.pt_desc1 + '  ' + data.pt_desc2 + ' [ ' + drawing +
                                    '<a href=http://localhost:51059/Parents.aspx?item=' + data.ps_comp + '>Parents</a> |' +
                                    '<a href=http://localhost:51059/ProdStruct.aspx?item=' + data.ps_comp + '>PS</a> ]</li>');
                                }
                                
                            }
                            else {

                                if ($("#child-items ul li:contains(" + data.ps_par + ")").length > 0) {
                                    let parent = $("#child-items ul li:contains(" + data.ps_par + ")").parent();
                                    
                                    parent.append('<ol><li style="list-style-type:none" class=' + phantom + '  value=' + data.ps_item_no + '>' + phantomText + ' <a href=http://localhost:51059/Item.aspx?item=' + data.ps_comp + '>' + data.ps_comp + '</a> ' +
                                        '(' + data.ps_qty_per + ' ' + data.pt_um + ') ' + data.pt_desc1 + '  ' + data.pt_desc2 + ' [ ' + drawing +
                                        '<a href=http://localhost:51059/Parents.aspx?item=' + data.ps_comp + '>Parents</a> |' +
                                        '<a href=http://localhost:51059/ProdStruct.aspx?item=' + data.ps_comp + '>PS</a> ]</li></ol>');
                                } else {
                                    $("#child-items ul").append("<li class=" + phantom + "  value=" + data.ps_item_no + ">" + phantomText + " <a href=http://localhost:51059/Item.aspx?item=" + data.ps_comp + ">" + data.ps_comp + "</a> " +
                                    "(" + data.ps_qty_per + " " + data.pt_um + ") " + data.pt_desc1 + "  " + data.pt_desc2 + " [ " + drawing +
                                    "<a href=http://localhost:51059/Parents.aspx?item=" + data.ps_comp + ">Parents</a> |" +
                                    "<a href=http://localhost:51059/ProdStruct.aspx?item=" + data.ps_comp + ">PS</a> ]</li>");
                                } 
                                
                            }

                            if (urlParams.has('c')) { //  && urlParams.get('c') == 'y'                                                           
                                getChildren(data.ps_comp); // recursively get the children items.
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

            

            // Function to trim the part number
            function convertPartNum(component) {  
                if ($.isNumeric(component.substring(0, 1))) {
                    let index = (component.indexOf("-") + 1);
                    if (index > 0) {
                        if (($.isNumeric(component.substring(index, (index + 1))) || ((component.indexOf("-EX") + 1) > 0))) {
                            component = component.substring(0, (index - 1));
                        }
                    }
                }                
                return component;
            }

            if (urlParams.has('c')) { 
                $('#level-label').text('');
                $('#level-label').text('Exploded');
                $('#level a:nth-child(1)').css('display', 'none');
                $('#level a:nth-child(2)').show();
            }

            var rollUp = false;
            $("#rollup-btn").on("click", function (e) {
			    if (!rollUp) {
			      $("#child-ecn-tbl").hide();
			      $("#rollup-btn").text("+");
			      rollUp = true;
			    }
			    else {
			      $("#child-ecn-tbl").show();
			      $("#rollup-btn").text("-");
			      rollUp = false;
			    }
			});

        });
    </script>
</body>
</html>
