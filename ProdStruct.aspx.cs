using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using Newtonsoft.Json;
using System.Web.Script.Services;
using System.Net.Http;
using System.Threading.Tasks;
using System.Net;
using System.Xml;

namespace MFGPRO
{
    public partial class ProdStruct : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json)]
        public static string GetDrawingPath(string item, string revision, string drawing)
        {
            string retDwgPath = string.Empty;
            StringBuilder dwgPath = new StringBuilder();

            dwgPath.Append(drawing.Substring(0, 2));
            dwgPath.Append("\\");
            dwgPath.Append(drawing.Substring(2, 3));
            dwgPath.Append("\\");
            dwgPath.Append(drawing.Substring(5, 2));
            dwgPath.Append("_");
            dwgPath.Append(revision);
            dwgPath.Append(".pdf");

            retDwgPath = dwgPath.ToString();

            if (File.Exists("K:\\Department\\doc_con\\DWG\\REL\\" + retDwgPath))
            {
                retDwgPath.Replace("\\", "/");
                return retDwgPath;
            }
            else
            {
                dwgPath.Clear();
                // "drawing" param is empty. So, extract part of a drawing path from "item" param
                dwgPath.Append(item.Substring(0, 2));
                dwgPath.Append("\\");
                dwgPath.Append(item.Substring(2, 3));
                dwgPath.Append("\\");
                dwgPath.Append(item.Substring(5, 2));
                dwgPath.Append("_");
                dwgPath.Append(revision);
                dwgPath.Append(".pdf");

                retDwgPath = string.Empty;
                retDwgPath = dwgPath.ToString();

                if (File.Exists("K:\\Department\\doc_con\\DWG\\REL\\" + retDwgPath))
                {
                    retDwgPath.Replace("\\", "/");
                    return retDwgPath;
                }
            }
            return "";
        }

        
    }
}