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
                string action = context.Request.QueryString["action"] ?? "toggle";

                if (string.IsNullOrEmpty(pidStr)) {
                    context.Response.Write("{\"success\":false,\"message\":\"Invalid Product ID\"}");
                    return;
                }
                int pid = int.Parse(pidStr);
                string sid = context.Session.SessionID;
                string conStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

                bool inWishlist = false;

                using (SqlConnection con = new SqlConnection(conStr)) {
                    con.Open();

                    if (action == "remove") {
                        // Explicit remove
                        string delQ = "DELETE FROM WishlistItems WHERE ProductId = @pid AND SessionId = @sid";
                        using (SqlCommand cmd = new SqlCommand(delQ, con)) {
                            cmd.Parameters.AddWithValue("@pid", pid);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                        inWishlist = false;
                    } else {
                        // Toggle: check if already exists
                        string checkQ = "SELECT COUNT(*) FROM WishlistItems WHERE ProductId = @pid AND SessionId = @sid";
                        bool exists = false;
                        using (SqlCommand cmd = new SqlCommand(checkQ, con)) {
                            cmd.Parameters.AddWithValue("@pid", pid);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            exists = ((int)cmd.ExecuteScalar() > 0);
                        }

                        if (exists) {
                            // Already in wishlist → remove it
                            string delQ = "DELETE FROM WishlistItems WHERE ProductId = @pid AND SessionId = @sid";
                            using (SqlCommand cmd = new SqlCommand(delQ, con)) {
                                cmd.Parameters.AddWithValue("@pid", pid);
                                cmd.Parameters.AddWithValue("@sid", sid);
                                cmd.ExecuteNonQuery();
                            }
                            inWishlist = false;
                        } else {
                            // Not in wishlist → add it
                            string insQ = "INSERT INTO WishlistItems (ProductId, SessionId, AddedDate) VALUES (@pid, @sid, GETDATE())";
                            using (SqlCommand cmd = new SqlCommand(insQ, con)) {
                                cmd.Parameters.AddWithValue("@pid", pid);
                                cmd.Parameters.AddWithValue("@sid", sid);
                                cmd.ExecuteNonQuery();
                            }
                            inWishlist = true;
                        }
                    }

                    // Fetch updated total count for session
                    int count = 0;
                    string countQ = "SELECT COUNT(*) FROM WishlistItems WHERE SessionId = @sid";
                    using (SqlCommand cmd = new SqlCommand(countQ, con)) {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        count = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    string msg = inWishlist ? "Added to Wishlist!" : "Removed from Wishlist";
                    context.Response.Write("{\"success\":true, \"message\":\"" + msg + "\", \"inWishlist\":" + (inWishlist ? "true" : "false") + ", \"totalCount\":" + count + "}");
                }
            }
            catch (Exception ex) {
                context.Response.Write("{\"success\":false, \"message\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }
        public bool IsReusable { get { return false; } }
    }
}
