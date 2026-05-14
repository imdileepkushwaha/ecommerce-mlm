<%@ WebHandler Language="C#" Class="ecommerce_mlm.UpdateCart" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.SessionState;

namespace ecommerce_mlm
{
    public class UpdateCart : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            string action = context.Request["action"];
            string cidStr = context.Request["cid"]; // Can be numeric ID, or "all"
            
            if (string.IsNullOrEmpty(action) || string.IsNullOrEmpty(cidStr)) {
                context.Response.Write("{\"success\":false, \"message\":\"Invalid request\"}");
                return;
            }

            string sid = context.Session.SessionID;
            
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // HANDLING BULK ACTIONS
                    if (cidStr == "all") {
                        if (action == "delete") {
                            string sql = "DELETE FROM CartItems WHERE SessionId = @sid AND IsSavedForLater = 0";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                        else if (action == "save") {
                            string sql = "UPDATE CartItems SET IsSavedForLater = 1 WHERE SessionId = @sid AND IsSavedForLater = 0";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                        context.Response.Write("{\"success\":true}");
                        return;
                    }

                    // HANDLING SINGLE ITEM ACTIONS
                    int cid = Convert.ToInt32(cidStr);
                    
                    // Safety Verification Check
                    string verify = "SELECT COUNT(*) FROM CartItems WHERE CartItemId = @cid AND SessionId = @sid";
                    SqlCommand vCmd = new SqlCommand(verify, con);
                    vCmd.Parameters.AddWithValue("@cid", cid);
                    vCmd.Parameters.AddWithValue("@sid", sid);
                    if (Convert.ToInt32(vCmd.ExecuteScalar()) == 0) {
                        context.Response.Write("{\"success\":false, \"message\":\"Access Denied\"}");
                        return;
                    }

                    if (action == "update")
                    {
                        int qty = Convert.ToInt32(context.Request["qty"]);
                        if (qty < 1) qty = 1;

                        // Verify stock
                        string stkQ = "SELECT p.Stock FROM CartItems c INNER JOIN SellerProducts p ON c.ProductId = p.Id WHERE c.CartItemId = @cid";
                        SqlCommand stkCmd = new SqlCommand(stkQ, con);
                        stkCmd.Parameters.AddWithValue("@cid", cid);
                        int productStock = Convert.ToInt32(stkCmd.ExecuteScalar() ?? 0);

                        if (qty > productStock) {
                            context.Response.Write("{\"success\":false, \"error\":\"Stock limit reached. Max available: " + productStock + "\"}");
                            return;
                        }

                        string sql = "UPDATE CartItems SET Quantity = @q WHERE CartItemId = @cid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@q", qty);
                        cmd.Parameters.AddWithValue("@cid", cid);
                        cmd.ExecuteNonQuery();
                    }
                    else if (action == "delete")
                    {
                        string sql = "DELETE FROM CartItems WHERE CartItemId = @cid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@cid", cid);
                        cmd.ExecuteNonQuery();
                    }
                    else if (action == "save") // Move to Saved for Later
                    {
                        string sql = "UPDATE CartItems SET IsSavedForLater = 1 WHERE CartItemId = @cid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@cid", cid);
                        cmd.ExecuteNonQuery();
                    }
                    else if (action == "movetocart") // Move Back to Active Cart
                    {
                        string sql = "UPDATE CartItems SET IsSavedForLater = 0 WHERE CartItemId = @cid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@cid", cid);
                        cmd.ExecuteNonQuery();
                    }
                }
                context.Response.Write("{\"success\":true}");
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false, \"error\":\"" + ex.Message + "\"}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
