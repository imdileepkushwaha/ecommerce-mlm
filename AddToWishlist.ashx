<%@ WebHandler Language="C#" Class="ecommerce_mlm.AddToWishlist" %>
using System;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;
using System.Configuration;

namespace ecommerce_mlm {
    public class AddToWishlist : IHttpHandler, IRequiresSessionState {
        public void ProcessRequest(HttpContext context) {
            context.Response.ContentType = "application/json";
            try {
                string pidStr = context.Request.QueryString["pid"];
                string action = context.Request.QueryString["action"] ?? "add";

                if (string.IsNullOrEmpty(pidStr)) {
                    context.Response.Write("{\"success\":false,\"message\":\"Invalid Product ID\"}");
                    return;
                }
                int pid = int.Parse(pidStr);
                string sid = context.Session.SessionID;
                string conStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

                using (SqlConnection con = new SqlConnection(conStr)) {
                    con.Open();
                    
                    if (action == "remove") {
                        string delQ = "DELETE FROM WishlistItems WHERE ProductId = @pid AND SessionId = @sid";
                        using (SqlCommand cmd = new SqlCommand(delQ, con)) {
                            cmd.Parameters.AddWithValue("@pid", pid);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    } else {
                        // Check duplicate
                        string checkQ = "SELECT COUNT(*) FROM WishlistItems WHERE ProductId = @pid AND SessionId = @sid";
                        bool exists = false;
                        using (SqlCommand cmd = new SqlCommand(checkQ, con)) {
                            cmd.Parameters.AddWithValue("@pid", pid);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            exists = ((int)cmd.ExecuteScalar() > 0);
                        }

                        if (!exists) {
                            // Insert
                            string insQ = "INSERT INTO WishlistItems (ProductId, SessionId, AddedDate) VALUES (@pid, @sid, GETDATE())";
                            using (SqlCommand cmd = new SqlCommand(insQ, con)) {
                                cmd.Parameters.AddWithValue("@pid", pid);
                                cmd.Parameters.AddWithValue("@sid", sid);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }

                    // Fetch final total count after operation to send to UI
                    int count = 0;
                    string countQ = "SELECT COUNT(*) FROM WishlistItems WHERE SessionId = @sid";
                    using (SqlCommand cmd = new SqlCommand(countQ, con)) {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        count = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    context.Response.Write("{\"success\":true, \"message\":\"Operation completed\", \"totalCount\":" + count + "}");
                }
            }
            catch (Exception ex) {
                context.Response.Write("{\"success\":false, \"message\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }
        public bool IsReusable { get { return false; } }
    }
}
