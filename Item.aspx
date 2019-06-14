<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Item.aspx.cs" Inherits="MFGPRO_dotnet.Item" %>

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

    <div id="item-qry-str">
        <input id="item-hid" type="hidden" value="<%=Request.QueryString["item"]%>"/>
        <input id="item-no" type="hidden"/>
        <input id="rev-no" type="hidden"/>
        <input id="drawing-no" type="hidden"/>
    </div>
    <br/>
    <div id="item-out" class="manuAlign container">
        <h5 class="srchResTable">
            <a href="Item.aspx?item=<%=Request.QueryString["item"]%>"><%=Request.QueryString["item"]%></a> 
            <small>
                <span id="desc1"></span><span id="desc2"></span>
                [<span id="view-draw"></span> <span id="parents"><a href="Parents.aspx?item=<%=Request.QueryString["item"]%>">Parents</a></span>]
            </small>
        </h5>

        <br/>

        <h5>Item Data</h5>
        <table id="item-data" class="table-sm sub-item-det margin-auto"></table>
            
        <br/>

        <h5>Inventory Data</h5>
        <table id="inventory-data" class="table-sm sub-item-det margin-auto"></table>

        <br/>

        <h5>Italian Data</h5>
        <table id="italian-data" class="table-sm sub-item-det margin-auto"></table>

        <br/>

        <h5>Planning Data</h5>
        <table id="planning-data" class="table-sm sub-item-det margin-auto"></table>

        <br/>

        <h5>Supplier Information</h5>
        <table id="supplier-data" class="table-sm sub-item-det margin-auto">
            <thead>
                <tr>
                    <th>Vendor</th>
                    <th>Vendor Part</th>
                    <th>Mfg</th>
                    <th>Mfg Part</th>
                </tr>
            </thead>
        </table>

        <br/>

        <h5>Price Data</h5>
        <table id="price-data" class="table-sm sub-item-det margin-auto"></table>

        <br/>

        <h5>Standard Cost</h5>
        <table id="stdCost-data" class="table-sm sub-item-det margin-auto">
            <thead>
                <tr>
                    <th>Element</th>
                    <th>This Level</th>
                    <th>Lower Level</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>

        <br/>

        <h5>Current Cost</h5>
        <table id="curCost-data" class="table-sm sub-item-det margin-auto">
            <thead>
                <tr>
                    <th>Element</th>
                    <th>This Level</th>
                    <th>Lower Level</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>

        <br/>
        
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

                    if ((drawing == "NONE") || (drawing == "")) {      
                        console.log("There is no drawing for the part :"+item);                       
                    } else {
                        let retDraw = getDrawPath(item, revision, drawing);                          
                        $("#view-draw").append(retDraw); // Set the "View Drawing" if drawing exists.
                    }

                    renderDetails(parsedData); // render the part_master details.                    

                    getInventory(item); // fetch inventory.

                    getSupplier(item); // fetch the supplier data.

                    getSptDetail(item, 'STANDARD'); // fetch cost simulation item detail for the STANDARD Cost setting.
                    getSptDetail(item, 'CURRENT'); // fetch cost simulation item detail for the CURRENT Cost setting.

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

            function getInventory(item) {
                $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    data: { part: item },
                    url: "http://localhost:51059/api/Mfgpro/GetInventory",
                    success: function (data) {
                        var parsedInv = JSON.parse(data);

                        renderDetails(parsedInv); // render the parsed inventory details.                                              
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                    }
                });
            }

            function getSupplier(item) {
                $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    data: { part: item },
                    url: "http://localhost:51059/api/Mfgpro/GetSupplier",
                    success: function (data) {
                        var parsedSup = JSON.parse(data);

                        renderDetails(parsedSup); // render the parsed inventory details.                                              
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                    }
                });
            }            

            // Cost Simulation Item Detail
            function getSptDetail(item, costSet) {
                $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    data: { part: item, costSet : costSet },
                    url: "http://localhost:51059/api/Mfgpro/GetSptDetail",
                    success: function (data) {
                        var parsedSpt = JSON.parse(data);

                        renderDetails(parsedSpt); // render the parsed SPT details.
                                             
                        getSctDetail(item, 'STANDARD'); // fetch cost simulation total detail for the STANDARD cost setting.                                                                
                        
                        getSctDetail(item, 'CURRENT'); // fetch cost simulation total detail for the CURRENT cost setting.
                        
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
                    }
                });
            }

            // Cost Simulation Total Detail
            function getSctDetail(item, costSet) {
                $.ajax({
                    type: "GET",
                    dataType: "JSON",
                    contentType: "application/JSON; charset=utf-8",
                    data: { part: item, costSet: costSet },
                    url: "http://localhost:51059/api/Mfgpro/GetSctDetail",
                    success: function (data) {
                        var parsedSct = JSON.parse(data);
                        
                        renderDetails(parsedSct); // render the parsed SCT details.                                              
                    },
                    error: function (xhr, errorType, exception) {
                        console.log("Error : " + xhr.responseText);
                    },
                    failure: function (response) {
                        console.log("Failure : " + response.responseText);
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

            function renderDetails(data) {

                if (!($.isEmptyObject(data))) {                                        
                    $.each(data, function (i, data) {
                        if (data.pt_part) { // data from pt_mstr. 

                            /*Item data*/
                            $('#item-data').append('<tr><th>Product Line: </th><td>' + data.pt_prod_line +
                                '</td><th>Item Type: </th><td>' + data.pt_part_type + '</td><th>Drawing: </th><td>' + data.pt_draw +
                                '</td></tr>');

                            if (!(data.pt_added === undefined)) {
                                var dateAdded = data.pt_added;                                
                                dateAdded = dateAdded.split('T')[0];
                                let year = dateAdded.split('-')[0];
                                let month = dateAdded.split('-')[1];
                                let date = dateAdded.split('-')[2];
                                dateAdded = month + '/' + date + '/' + year;                                
                            }

                            $('#item-data').append('<tr><th>Added: </th><td>' + dateAdded +
                                '</td><th>Status: </th><td>' + data.pt_status + '</td><th>Rev: </th><td>' + data.pt_rev +
                                '</td></tr>');

                            $('#item-data').append('<tr><th>UM: </th><td>' + data.pt_um +
                                '</td><th>Group: </th><td>' + data.pt_group + '</td><th>Drawing Loc: </th><td>' + data.pt_dwg_loc +
                                '</td></tr>');

                            /*Inventory data*/
                            $('#inventory-data').append('<tr><th>ABC Class: </th><td>' + data.pt_abc +
                                '</td><th>Avg Int: </th><td>' + data.pt_avg_int + '</td></tr>');

                            $('#inventory-data').append('<tr><th>Lot/Serial Control: </th><td>' + data.pt_lot_ser +
                                '</td><th>Cyc Cnt Int: </th><td>' + data.pt_cyc_int + '</td></tr>');

                            $('#inventory-data').append('<tr><th>Site: </th><td>' + data.pt_site +
                                '</td><th>Shelf Life: </th><td>' + data.pt_shelflife + '</td></tr>');

                            $('#inventory-data').append('<tr><th>Location: </th><td>' + data.pt_loc +
                                '</td><th>Allocate Single Lot: </th><td>' + data.pt_sngl_lot + '</td></tr>');

                            $('#inventory-data').append('<tr><th>Location Type: </th><td>' + data.pt_loc_type +
                                '</td><th>Critical Item: </th><td>' + data.pt_critical + '</td></tr>');

                            $('#inventory-data').append('<tr><th>Auto Lot Numbers: </th><td>' + data.pt_auto_lot +
                                '</td><th>Article Number: </th><td>' + data.pt_article + '</td></tr>');

                            /*Italian data*/
                            $('#italian-data').append('<tr><th>Parent Part: </th><td>' + data.pt__chr03 +
                                '</td><th>Group: </th><td>' + data.pt__chr02 + '</td><th>Application: </th><td>' + data.pt__chr01 +
                                '</td></tr>');

                            /*Planning data*/
                            $('#planning-data').append('<tr><th>Master Sched: </th><td>' + data.pt_ms +
                                '</td><th>Buyer/Planner: </th><td>' + data.pt_buyer + '</td><th>Issue Policy: </th><td>' + data.pt_iss_pol +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Plan Orders: </th><td>' + data.pt_plan_ord +
                                '</td><th>Supplier: </th><td>' + data.pt_vend + '</td><th>Phantom: </th><td>' + data.pt_phantom +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Time Fence: </th><td>' + data.pt_timefence +
                                '</td><th>PO Site: </th><td>' + data.pt_po_site + '</td><th>Min Order: </th><td>' + data.pt_ord_min +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>MRP Required: </th><td>' + data.pt_mrp +
                                '</td><th>Pur/Mfg: </th><td>' + data.pt_pm_code + '</td><th>Max Order: </th><td>' + data.pt_ord_max +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Order Policy: </th><td>' + data.pt_ord_pol +
                                '</td><th>Mfg LT: </th><td>' + data.pt_mfg_lead + '</td><th>Order Mult: </th><td>' + data.pt_ord_mult +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Order Qty: </th><td>' + data.pt_ord_qty +
                                '</td><th>Pur LT: </th><td>' + data.pt_pur_lead + '</td><th>Yield %: </th><td>' + data.pt_yield_pct +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Batch Qty: </th><td>' + data.pt_batch +
                                '</td><th>Inspect: </th><td>' + data.pt_insp_rqd + '</td><th>Run Time: </th><td>' + data.pt_run +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Order Period: </th><td>' + data.pt_ord_per +
                                '</td><th>Ins LT: </th><td>' + data.pt_insp_lead + '</td><th>Setup Time: </th><td>' + data.pt_setup +
                                '</td></tr>');

                            $('#planning-data').append('<tr><th>Safety Stk: </th><td>' + data.pt_sfty_stk +
                                '</td><th>Cum LT: </th><td>' + data.pt_cum_lead + '</td><th class="highlight"><u>Quantities</u></th><td class="highlight"></td></tr>');

                            $('#planning-data').append('<tr><th>Safety Time: </th><td>' + data.pt_sfty_time +
                                '</td><th>Network Code: </th><td>' + data.pt_network + '</td><th class="highlight"><small>On Hand:</small></th></tr>');

                            $('#planning-data').append('<tr><th>Reorder Point: </th><td>' + data.pt_rop +
                                '</td><th>Routing Code: </th><td>' + data.pt_routing + '</td><th class="highlight"><small>Available:</small></th></tr>');

                            $('#planning-data').append('<tr><th>Revision: </th><td>' + data.pt_rev +
                                '</td><th>Bill of Material: </th><td>' + data.pt_bom_code + '</td><th class="highlight"><small>On Order:</small></th></tr>');

                            /*Price data*/
                            $('#price-data').append('<tr><th>Price: </th><td>' + data.pt_price +
                                '</td><th>Tax: </th><td>' + data.pt_taxable + '</td><th>Tax Class: </th><td>' + data.pt_taxc + '</td></tr>');

                        } else if (data.in_part) { // data from in_mstr.

                            let qtyOh = Number.parseInt(data.in_qty_oh);
                            let qtyAvail = ((qtyOh) - (Number.parseInt(data.in_qty_all)));
                            let onOrder = Number.parseInt(data.in_qty_ord);

                            $('#planning-data tr th:contains("On Hand:")').after('<td class="highlight"><small>' + qtyOh + '</small></td>');
                            $('#planning-data tr th:contains("Available:")').after('<td class="highlight"><small>' + qtyAvail + '</small></td>');
                            $('#planning-data tr th:contains("On Order:")').after('<td class="highlight"><small>' + onOrder + '</small></td>');

                        } else if (data.VENDOR) {   // data from supplier.

                            $('#supplier-data').append('<tbody><tr><td>' + data.VENDOR + '(' + data.vp_vend + ')</td><td>' + data.vp_vend_part +
                                '</td><td>' + data.vp_mfgr + '</td><td>' + data.vp_mfgr_part + '</td></tbody>');

                        } else if (data.spt_element) {   // data from spt.

                            let cost = Number.parseFloat(data.spt_cst_tl).toFixed(2);
                            let costLL = Number.parseFloat(data.spt_cst_ll).toFixed(2);
                            let costTotal = Number.parseFloat((data.spt_cst_tl) + (data.spt_cst_ll)).toFixed(2);

                            if ((data.spt_sim) == 'Standard') {
                                $('#stdCost-data tbody').append('<tr><td>' + data.spt_element + '</td><td>' + cost +
                                    '</td><td>' + costLL + '</td><td>' + costTotal + '</td>');   // for standard cost. 
                            } 

                            if ((data.spt_sim) == 'Current') { 
                                $('#curCost-data tbody').append('<tr><td>' + data.spt_element + '</td><td>' + cost +
                                '</td><td>' + costLL + '</td><td>' + costTotal + '</td>');   // for current cost.
                            }                                               
                            
                        } else if (data.sct_sim) {  // data from sct.
                            
                            let thisLevelTotal = Number.parseFloat((data.sct_mtl_tl) + (data.sct_bdn_tl) + (data.sct_lbr_tl) + (data.sct_sub_tl) + (data.sct_ovh_tl)).toFixed(2);
                            let lowerLevelTotal = Number.parseFloat((data.sct_mtl_ll) + (data.sct_bdn_ll) + (data.sct_lbr_ll) + (data.sct_sub_ll) + (data.sct_ovh_ll)).toFixed(2);
                            let totalsTotal = Number.parseFloat(data.sct_cst_tot).toFixed(2);

                            if (((data.sct_sim) == 'Standard') && (!($('#stdCost-data tbody tr:contains("Total")').length > 0))) {
                                $('#stdCost-data tbody tr:last').after('<tr><td><strong>Total:</strong></td><td><strong>' + thisLevelTotal + '</strong></td><td><strong>' + lowerLevelTotal +
                                    '</strong></td><td><strong>' + totalsTotal + '</strong></td></tr>');  // standard cost. 
                            } 

                            if (((data.sct_sim) == 'Current') && ((!($('#curCost-data tbody tr:contains("Total")').length > 0)))) {
                                $('#curCost-data tbody tr:last').after('<tr><td><strong>Total:</strong></td><td><strong>'+ thisLevelTotal +'</strong></td><td><strong>'+ lowerLevelTotal+
                                 '</strong></td><td><strong>' + totalsTotal + '</strong></td></tr>'); // current cost.
                            }                       
                                                       
                            
                        } else {
                            alert('something else !');                            
                        }
                    });                                            
                }                
            }

        });
    </script>
</body>
</html>
