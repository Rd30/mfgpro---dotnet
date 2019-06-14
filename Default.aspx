<!DOCTYPE html>
<html>
<head runat="server">
    <!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloHead.html" -->
</head>
<body class="mfgproBody">
    <!-- Dark overlay element -->
	<div class="overlay" id="overlay"></div>

	<!--NavBar/Header-->
	<div class="all-gp-sloHeader" id="itemHeader"><!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloHeader.html" --></div>

	<!--SideBar-->
	<!-- #include file = "C:\inetpub\wwwroot\gp-slo\common\gp-sloSidebar.html" -->

    <div class="gp-slo-container container" id="mfgproMainContainer">
        
        <!--prod struct div-->
        <div class="row" id="prodStructDiv">
            <div class="pull-left col-md-6">
                <h6 class="margin-auto"><strong>Documentation</strong></h6>
                <br>
                <div>
                    <h6><a >MFGPRO 9.0 Documentation</a></h6>
                </div>
            </div>
            <div class="pull-right col-md-6">
                <h6><strong>Data from MFGPRO</strong></h6>
                <br>
                <div>
                    <h6 class="margin-auto"><a href="http://localhost:51059/ProdStruct.aspx?item=4100037">Product Structure</a></h6>
                    <br>
                    <form id="prod-struct-form" method="GET" action="SearchResults.aspx">
                        <div class="form-group row">
                            <label for="prod-struct-item" class="col-md-2 col-form-label">Item:</label>
                            <div class="col-md-8">
                              <input name="item" type="text" class="form-control" id="prod-struct-item" >
                            </div>
                            <div class="col-md-2"><button id="prod-struct-lookup" type="submit" class="btn btn-primary">Lookup</button></div>
                        </div>
                        <div class="form-group row">
                            <label for="prod-struct-desc" class="col-md-2 col-form-label">Desc:</label>
                            <div class="col-md-8">
                              <input name="desc" type="text" class="form-control" id="prod-struct-desc" >
                            </div>
                            <div class="col-md-2"><input type="hidden" name="return" value="ProdStruct.aspx"></div>
                        </div>                    
                    </form>
                </div>
            </div>
        </div> <!--prod struct div-->
        
        <br/>

        <!--item detail div-->
        <div class="row" id="itemDetailDiv"> 
            <div class="pull-left col-md-6">                
                <div>
                    <h6><a >MFGPRO 9.0 Service Pack 6 Documentation</a></h6>
                </div>
            </div>
            <div class="pull-right col-md-6">                
                <div>
                    <h6 class="margin-auto"><a href="http://localhost:51059/Item.aspx?item=4100037">Item Detail</a></h6>
                    <br>
                    <form id="item-detail-form" method="GET" action="SearchResults.aspx">
                        <div class="form-group row">
                            <label for="item-detail-item" class="col-md-2 col-form-label">Item:</label>
                            <div class="col-md-8">
                              <input name="item" type="text" class="form-control" id="item-detail-item" >
                            </div>
                            <div class="col-md-2"><button id="item-detail-lookup" type="submit" class="btn btn-primary">Lookup</button></div>
                        </div>
                        <div class="form-group row">
                            <label for="item-detail-desc" class="col-md-2 col-form-label">Desc:</label>
                            <div class="col-md-8">
                              <input name="desc" type="text" class="form-control" id="item-detail-desc" >
                            </div>
                            <div class="col-md-2"><input type="hidden" name="return" value="Item.aspx"></div>
                        </div>                    
                    </form>
                </div>
            </div>
        </div> <!--item detail div-->

        <br/>

        <!--parent items div-->
        <div class="row" id="parentItemsDiv"> 
            <div class="pull-left col-md-6">                
                <div>
                    <h6><a >How to use Drawings on the Intranet</a></h6>
                </div>
            </div>
            <div class="pull-right col-md-6">                
                <div>
                    <h6 class="margin-auto"><a href="http://localhost:51059/Parents.aspx?item=4100037">Parent Items</a></h6>
                    <br>
                    <form id="parent-items-form" method="GET" action="SearchResults.aspx">
                        <div class="form-group row">
                            <label for="parent-items-item" class="col-md-2 col-form-label">Item:</label>
                            <div class="col-md-8">
                              <input name="item" type="text" class="form-control" id="parent-items-item" >
                            </div>
                            <div class="col-md-2"><button id="parent-items-lookup" type="submit" class="btn btn-primary">Lookup</button></div>
                        </div>
                        <div class="form-group row">
                            <label for="parent-items-desc" class="col-md-2 col-form-label">Desc:</label>
                            <div class="col-md-8">
                              <input name="desc" type="text" class="form-control" id="parent-items-desc" >
                            </div>
                            <div class="col-md-2"><input type="hidden" name="return" value="Parents.aspx"></div>
                        </div>                    
                    </form>
                </div>
            </div>
        </div> <!--parent items div-->
        
                
    </div>


    <script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
	<script type="text/javascript">
		$(document).ready(function () {
			$('#pageTitleDiv').html("");
			$('#pageTitleDiv').html("<h5>MFGPRO</h5>");
			$('#shortPageTitleDiv').html("");
			$('#shortPageTitleDiv').html("<h5>MFGPRO</h5>");
		})
	</script>
</body>
</html>