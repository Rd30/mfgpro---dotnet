<!DOCTYPE html>
<html>
<head>
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
    
    <div id="qry-str">
        <input id="item-hid" type="hidden" value="<%=Request.QueryString("item").ToString()%>">
        <input id="desc-hid" type="hidden" value="<%=Request.QueryString("desc").ToString()%>">
        <input id="return-hid" type="hidden" value="<%=Request.QueryString("return").ToString()%>">
    </div>

    <div class="container">
        <div class="alert alert-danger text-center" role="alert" hidden></div>   
    </div>
         
    

    <div class="container" id="sr-outpt">
        <table id="sr-tbl" class="table table-sm srchResTable">                
          <thead class="table-dark"></thead>             
        </table>
    </div>
    
    <script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
	<script type="text/javascript">
        $(document).ready(function () {            
            var psSpinner = $('.loading');	
			    psSpinner.show();   // Displays loading icon until AJAX success

            $('#pageTitleDiv').html("");
			$('#pageTitleDiv').html("<h5>MFGPRO</h5>");
			$('#shortPageTitleDiv').html("");
            $('#shortPageTitleDiv').html("<h5>MFGPRO</h5>");
                        
            var itemVal = $("#item-hid").val();
            var descVal = $("#desc-hid").val();
            var retVal = $("#return-hid").val();            
            
            $.ajax({
                type: "GET",
                dataType: "JSON",
                contentType: "application/JSON; charset=utf-8",
                data: {item: itemVal, desc: descVal},
                url: "http://localhost:51059/api/Mfgpro/SearchResults",
                success: function (data) {
                    var parsedData = JSON.parse(data);
                    if (parsedData.length == 0) { //No Match

                        $("#sr-outpt").attr("hidden", true);
                        $(".alert").attr("hidden", false);
                        $(".alert").text("There are no items that matches your search criteria !");

                    } else if (parsedData.length == 1) {  // Found the exact match of what you are looking for !

                        var retItem;
                        $.each(parsedData, function (i, data) {
                           retItem = data.pt_part;                            
                        })
                        
                        window.location.replace("http://localhost:51059/" + retVal + "?item=" + retItem);

                    } else {     //Multiple match                    

                        $("#sr-tbl").bootstrapTable({
                               data: parsedData,
                               columns: [{
                                    field: 'pt_part',
                                    title: 'Item',
                                    sortable : true,
                                    formatter: (value, row, index, field) => {
                                        return "<a href=http://localhost:51059/"+retVal+"?item="+row.pt_part+">"+row.pt_part+"</a>";
                                    } 
                                },
                                {
                                    field: 'pt_desc1',
                                    title: 'Description',
                                    sortable : true,
                                    formatter: (value, row, index, field) => {
                                        return row.pt_desc1 +""+ row.pt_desc2
                                    }
                                }]                                                 
                        });
                        $(".fixed-table-loading").attr("hidden", true);                        
                    }
                        $('.loading').attr("hidden", true); // Hide the loading icon/screen
                },
                error: function (xhr, errorType, exception) {                        
                    alert("Error : " + xhr.responseText);
                    $("#sr-outpt").attr("hidden", true);
                    $(".alert").attr("hidden", false);
                    $(".alert").text("Error ! Please contact IT");
                },
                failure: function (response) {                        
                    alert("Failure : " + response.responseText);
                    $("#sr-outpt").attr("hidden", true);
                    $(".alert").attr("hidden", false);
                    $(".alert").text("Error ! Please contact IT");
                }               
            });
		})
	</script>
</body>
</html>