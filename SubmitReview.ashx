<%@ WebHandler Language="C#" Class="ecommerce_mlm.SubmitReview" %>
using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;

namespace ecommerce_mlm {
    public class SubmitReview : IHttpHandler {
        public void ProcessRequest(HttpContext context) {
            context.Response.ContentType = "application/json";
            try {
                int pid = int.Parse(context.Request.Form["pid"]);
                string name = context.Request.Form["name"];
                string msg = context.Request.Form["msg"];
                int rating = int.Parse(context.Request.Form["rating"]);
                
                if(string.IsNullOrEmpty(name) || string.IsNullOrEmpty(msg)) {
                     context.Response.Write("{\"success\":false,\"message\":\"Fill name and message.\"}");
                     return;
                }

                string conStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(conStr)) {
                    con.Open();
                    string q = "INSERT INTO ProductReviews (ProductId, ReviewerName, Rating, ReviewText, ReviewDate, IsApproved) VALUES (@pid, @n, @r, @t, GETDATE(), 1)";
                    using(SqlCommand cmd = new SqlCommand(q, con)) {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@r", rating);
                        cmd.Parameters.AddWithValue("@t", msg);
                        cmd.ExecuteNonQuery();
                    }
                }
                context.Response.Write("{\"success\":true,\"message\":\"Review submitted successfully!\"}");
            } catch (Exception ex) {
                 context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"","'") + "\"}");
            }
        }
        public bool IsReusable { get { return false; } }
    }
}
