using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Data;
using System.Data.Odbc;
using System.Configuration;
using Newtonsoft.Json;
using System.Xml;

namespace MFGPRO.Controllers
{
    public class MfgproController : ApiController
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["SPG"].ConnectionString;

        [HttpGet]
        [ActionName("SearchResults")]
        public string SearchResults(string item, string desc)
        {   
            DataTable dataTable = new DataTable { TableName = "SRDataTable" };
            string JSONString = string.Empty;
            string query = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                if (string.IsNullOrEmpty(desc))
                {
                    query = "SELECT * " +
                    "FROM PUB.pt_mstr WHERE (pt_domain = 'SPG') AND " +
                    "(pt_part LIKE '%" + item + "%') " +
                    "ORDER BY pt_part";
                }
                else if (string.IsNullOrEmpty(item))
                {
                    query = "SELECT * " +
                    "FROM PUB.pt_mstr WHERE (pt_domain = 'SPG') AND " +
                    "(pt_desc1+pt_desc2 LIKE '%" + desc + "%') " +
                    "ORDER BY pt_desc1";
                }
                else
                {
                    query = "SELECT * " +
                    "FROM PUB.pt_mstr WHERE (pt_domain = 'SPG') AND " +
                    "(pt_part LIKE '%" + item + "%') AND (pt_desc1+pt_desc2 LIKE '%" + desc + "%') " +
                    "ORDER BY pt_part";
                 }



                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        } 

        [HttpGet]
        [ActionName("GetChildren")]
        public string GetChildren(string item)
        {
            DataTable dataTable = new DataTable { TableName = "GetChildrenDT" };
            string JSONString = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                string query = "SELECT ps.ps_par, ps.ps_comp, ps.ps_qty_per, ps.ps_item_no, ps.ps_ps_code, pt.pt_desc1, pt.pt_desc2, pt.pt_rev, pt.pt_draw, pt.pt_phantom, pt.pt_um " +
                    "FROM PUB.ps_mstr ps, PUB.pt_mstr pt " +
                    "WHERE (pt.pt_domain = ps.ps_domain) AND (pt.pt_part = ps.ps_comp) AND (ps.ps_domain = 'SPG') AND (ps.ps_par = '" + item + "') " +
                    "AND (ps.ps_start <= CURDATE() OR ps.ps_start IS NULL) AND (ps.ps_end >= CURDATE() OR ps.ps_end IS NULL) " +
                    "ORDER BY ps.ps_par, ps.ps_item_no, ps.ps_comp";

                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        }

        [HttpGet]
        [ActionName("GetParents")]
        public string GetParents(string item)
        {
            DataTable dataTable = new DataTable { TableName = "GetParentsDT" };
            string JSONString = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                string query = "SELECT ps_par, ps_comp, ps_qty_per, pt_mstr.pt_desc1, pt_mstr.pt_desc2, ps_item_no, ps_ps_code, pt_mstr.pt_phantom, ptmstr.pt_um, pt_mstr.pt_rev, ptmstr.pt_draw " +
                    "FROM PUB.ps_mstr, PUB.pt_mstr, PUB.pt_mstr ptmstr " +
                    "WHERE (pt_mstr.pt_domain = ps_domain) AND (pt_mstr.pt_part = ps_par) AND (ptmstr.pt_domain = ps_domain) AND " +
                    "(ptmstr.pt_part = ps_comp) AND (ps_domain = 'SPG') AND (ps_comp = '" + item + "') AND " +
                    "(ps_start <= CURDATE() OR ps_start IS NULL) AND (ps_end >= CURDATE() OR ps_end IS NULL) " +
                    "ORDER BY pt_mstr.pt_desc1, pt_mstr.pt_desc2";


                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        }

        [HttpGet]
        [ActionName("GetInventory")]
        public string GetInventory(string part)
        {
            DataTable dataTable = new DataTable { TableName = "InvDataTable" };
            string JSONString = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                String query = "SELECT in_part, in_qty_oh, in_qty_all, in_qty_ord " +
                    "FROM PUB.in_mstr WHERE (in_domain = 'SPG') AND " +
                    "(in_site = 'AA00') AND (in_part LIKE '%" + part + "%')";

                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        }

        [HttpGet]
        [ActionName("GetSupplier")]
        public string GetSupplier(string part)
        {
            DataTable dataTable = new DataTable { TableName = "SupDataTable" };
            string JSONString = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                String query = "SELECT vd.vd_sort AS vendor, vp.*, vd.* " +
                    "FROM PUB.vp_mstr vp, PUB.vd_mstr vd " +
                    "WHERE (vp.vp_domain = 'SPG') AND (vp.vp_part LIKE '%" + part + "%') " +
                    "AND (vd.vd_sort IN (SELECT vd_sort FROM PUB.vd_mstr WHERE (vd_domain = 'SPG') AND (vd_addr = vp.vp_vend)))";


                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        }

        [HttpGet]
        [ActionName("GetSctDetail")]
        public string GetSctDetail(string part, string costSet)
        {
            DataTable dataTable = new DataTable { TableName = "SctDetailDataTable" };
            string JSONString = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                String query = "SELECT * " +
                    "FROM PUB.sct_det " +
                    "WHERE (sct_domain = 'SPG') AND (sct_site = 'AA00') AND (sct_sim = '" + costSet + "') AND (sct_part LIKE '%" + part + "%')";


                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        }

        [HttpGet]
        [ActionName("GetSptDetail")]
        public string GetSptDetail(string part, string costSet)
        {
            DataTable dataTable = new DataTable { TableName = "SptDetailDataTable" };
            string JSONString = string.Empty;

            using (OdbcConnection con = new OdbcConnection(connectionString))
            {
                String query = "SELECT * " +
                    "FROM PUB.spt_det " +
                    "WHERE (spt_domain = 'SPG') AND (spt_site = 'AA00') AND (spt_sim = '" + costSet + "') AND (spt_part LIKE '%" + part + "%') "+
                    "ORDER BY spt_element";


                con.Open();

                OdbcDataAdapter da = new OdbcDataAdapter(query, con);

                da.Fill(dataTable);

                JSONString = JsonConvert.SerializeObject(dataTable);

                con.Close();
            }

            return JSONString;
        }

        [HttpGet]
        [ActionName("GetEcnXml")]
        public string GetEcnXml()
        {            
            WebRequest request = WebRequest.Create("http://nd-backdraft.entegris.com/local/ops/spgecr.nsf/Pending/ItemLookup?ReadViewEntries&Outputformat=XML&Start=1&Count=-1");
            request.Credentials = new NetworkCredential("ENTEGRIS\\spgscanme", "F1r3F7y");

            Dictionary<string, string> retObj = new Dictionary<string, string>();

            using (WebResponse response = request.GetResponse())
            {              
                string tmpKey = "";
                string tmpHtmlStr = "";                
                string curPosition = "1";                
                string tmpPosition = "1";                

                XmlDocument ecnXml = new XmlDocument();
                ecnXml.Load(response.GetResponseStream());

                XmlNodeList items = ecnXml.SelectNodes("/viewentries/viewentry");
                
                foreach (XmlNode xItem in items) {

                    tmpPosition = xItem.Attributes["position"].Value;
                    bool temp = int.TryParse(tmpPosition, out int result);                    
                    if (temp) {
                      curPosition = result.ToString();                        
                    }

                    if (curPosition == tmpPosition) {
                        if (!(tmpKey == "")) {                            
                            if (!(retObj.ContainsKey(tmpKey))){
                                retObj.Add(tmpKey, tmpHtmlStr);
                            }               
                            tmpKey = "";
                            tmpHtmlStr = "";
                        }
                        tmpKey = xItem.InnerText;
                    }
                    else {
                        tmpHtmlStr = tmpHtmlStr + xItem.InnerText;
                    }

                }                
            }

            string JSONString = string.Empty;            
            JSONString = JsonConvert.SerializeObject(retObj);
            return JSONString;
        }        

    }
}
