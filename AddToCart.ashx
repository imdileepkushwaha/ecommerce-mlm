<%@ WebHandler Language="C#" Class="ecommerce_mlm.AddToCart" %>

using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.SessionState;

namespace ecommerce_mlm
{
    public class AddToCart : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            
            try
            {
                string productIdStr = context.Request["pid"];
                if (string.IsNullOrEmpty(productIdStr))
                {
                    context.Response.Write("{\"success\":false, \"message\":\"Missing Product ID\"}");
                    return;
                }
                
                int productId = Convert.ToInt32(productIdStr);
                string sessionId = context.Session.SessionID;
                
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // 1. Check if product already exists in cart for this session
                    string checkQuery = "SELECT CartItemId, Quantity FROM CartItems WHERE ProductId = @pid AND SessionId = @sid";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, con);
                    checkCmd.Parameters.AddWithValue("@pid", productId);
                    checkCmd.Parameters.AddWithValue("@sid", sessionId);
                    
                    con.Open();
                    SqlDataReader dr = checkCmd.ExecuteReader();
                    
                    bool exists = dr.Read();
                    int cartItemId = 0;
                    int existingQty = 0;
                    
                    if (exists)
                    {
                        cartItemId = Convert.ToInt32(dr["CartItemId"]);
                        existingQty = Convert.ToInt32(dr["Quantity"]);
                    }
                    dr.Close();
                    
                    if (exists)
                    {
                        // Update Quantity
                        string updateQuery = "UPDATE CartItems SET Quantity = @qty WHERE CartItemId = @cid";
                        SqlCommand upCmd = new SqlCommand(updateQuery, con);
                        upCmd.Parameters.AddWithValue("@qty", existingQty + 1);
                        upCmd.Parameters.AddWithValue("@cid", cartItemId);
                        upCmd.ExecuteNonQuery();
                    }
                    else
                    {
                        // Insert New
                        string insQuery = "INSERT INTO CartItems (ProductId, Quantity, SessionId, AddedDate) VALUES (@pid, 1, @sid, GETDATE())";
                        SqlCommand insCmd = new SqlCommand(insQuery, con);
                        insCmd.Parameters.AddWithValue("@pid", productId);
                        insCmd.Parameters.AddWithValue("@sid", sessionId);
                        insCmd.ExecuteNonQuery();
                    }
                }
                
                // Return new total quantity for current session to update header
                int totalCount = 0;
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string countQuery = "SELECT ISNULL(SUM(Quantity), 0) FROM CartItems WHERE SessionId = @sid";
                    SqlCommand countCmd = new SqlCommand(countQuery, con);
                    countCmd.Parameters.AddWithValue("@sid", sessionId);
                    con.Open();
                    totalCount = Convert.ToInt32(countCmd.ExecuteScalar());
                }

                context.Response.Write("{\"success\":true, \"totalCount\":" + totalCount + "}");
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false, \"message\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
