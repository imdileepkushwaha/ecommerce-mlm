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
                
                int requestQty = 1;
                if (!string.IsNullOrEmpty(context.Request["qty"])) {
                    int.TryParse(context.Request["qty"], out requestQty);
                }
                if (requestQty < 1) requestQty = 1;

                string size = context.Request["size"] ?? "";
                string color = context.Request["color"] ?? "";
                
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // 1. Check if product already exists in cart for this session
                    string checkQuery = "SELECT CartItemId, Quantity FROM CartItems WHERE ProductId = @pid AND SessionId = @sid AND ISNULL(SelectedSize, '') = @sz AND ISNULL(SelectedColor, '') = @clr";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, con);
                    checkCmd.Parameters.AddWithValue("@pid", productId);
                    checkCmd.Parameters.AddWithValue("@sid", sessionId);
                    checkCmd.Parameters.AddWithValue("@sz", size);
                    checkCmd.Parameters.AddWithValue("@clr", color);
                    
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
                    
                    // Check stock limit first
                    string stkQ = "SELECT Stock FROM SellerProducts WHERE Id = @pid";
                    SqlCommand stkCmd = new SqlCommand(stkQ, con);
                    stkCmd.Parameters.AddWithValue("@pid", productId);
                    int productStock = Convert.ToInt32(stkCmd.ExecuteScalar() ?? 0);

                    int targetQty = exists ? existingQty + requestQty : requestQty;

                    if (targetQty > productStock) {
                        context.Response.Write("{\"success\":false, \"message\":\"Cannot add " + requestQty + " more. Stock limit reached. Max available: " + productStock + "\"}");
                        return;
                    }

                    if (exists)
                    {
                        // Update Quantity
                        string updateQuery = "UPDATE CartItems SET Quantity = @qty WHERE CartItemId = @cid";
                        SqlCommand upCmd = new SqlCommand(updateQuery, con);
                        upCmd.Parameters.AddWithValue("@qty", targetQty);
                        upCmd.Parameters.AddWithValue("@cid", cartItemId);
                        upCmd.ExecuteNonQuery();
                    }
                    else
                    {
                        // Insert New
                        string insQuery = "INSERT INTO CartItems (ProductId, Quantity, SessionId, AddedDate, SelectedSize, SelectedColor) VALUES (@pid, @qty, @sid, GETDATE(), @sz, @clr)";
                        SqlCommand insCmd = new SqlCommand(insQuery, con);
                        insCmd.Parameters.AddWithValue("@pid", productId);
                        insCmd.Parameters.AddWithValue("@qty", targetQty);
                        insCmd.Parameters.AddWithValue("@sid", sessionId);
                        insCmd.Parameters.AddWithValue("@sz", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                        insCmd.Parameters.AddWithValue("@clr", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);
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
