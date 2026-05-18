<%@ WebHandler Language="C#" Class="ecommerce_mlm.admin.AdminSearchHandler" %>

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace ecommerce_mlm.admin
{
    public class AdminSearchHandler : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            try
            {
                if (context.Session == null || context.Session["AdminId"] == null)
                {
                    context.Response.StatusCode = 403;
                    context.Response.Write("{\"results\":[],\"error\":\"Not authenticated\"}");
                    return;
                }

                string role = context.Session["Role"] != null ? context.Session["Role"].ToString() : "";
                if (role != "Admin")
                {
                    context.Response.StatusCode = 403;
                    context.Response.Write("{\"results\":[],\"error\":\"Access denied\"}");
                    return;
                }

                string q = (context.Request["q"] ?? "").Trim();
                if (q.Length < 2)
                {
                    context.Response.Write("{\"results\":[]}");
                    return;
                }

                string like = "%" + q.Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]") + "%";
                var results = new List<object>();
                string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    string sqlUsers = @"SELECT TOP 5 Id, FullName, Email FROM Users
                        WHERE FullName LIKE @q OR Email LIKE @q OR Username LIKE @q OR CAST(Id AS VARCHAR(20)) LIKE @q
                        ORDER BY CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(sqlUsers, con))
                    {
                        cmd.Parameters.AddWithValue("@q", like);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                results.Add(new
                                {
                                    type = "user",
                                    id = dr["Id"].ToString(),
                                    title = dr["FullName"].ToString(),
                                    subtitle = dr["Email"].ToString(),
                                    url = "ManageUsers.aspx?q=" + HttpUtility.UrlEncode(q)
                                });
                            }
                        }
                    }

                    string sqlOrders = @"SELECT TOP 5 O.Id, O.OrderRef, U.FullName
                        FROM Orders O INNER JOIN Users U ON O.UserId = U.Id
                        WHERE CAST(O.Id AS VARCHAR(20)) LIKE @q OR O.OrderRef LIKE @q OR U.FullName LIKE @q OR U.Email LIKE @q
                        ORDER BY O.CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(sqlOrders, con))
                    {
                        cmd.Parameters.AddWithValue("@q", like);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                string orderRef = dr["OrderRef"] != DBNull.Value && !string.IsNullOrEmpty(dr["OrderRef"].ToString())
                                    ? dr["OrderRef"].ToString() : "Order #" + dr["Id"];
                                results.Add(new
                                {
                                    type = "order",
                                    id = dr["Id"].ToString(),
                                    title = orderRef,
                                    subtitle = dr["FullName"].ToString(),
                                    url = "ManageOrders.aspx?q=" + HttpUtility.UrlEncode(q)
                                });
                            }
                        }
                    }

                    string sqlSellers = @"SELECT TOP 5 Id, FullName, Email FROM SellerUsers
                        WHERE FullName LIKE @q OR Email LIKE @q OR CAST(Id AS VARCHAR(20)) LIKE @q
                        ORDER BY Id DESC";
                    using (SqlCommand cmd = new SqlCommand(sqlSellers, con))
                    {
                        cmd.Parameters.AddWithValue("@q", like);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                results.Add(new
                                {
                                    type = "seller",
                                    id = dr["Id"].ToString(),
                                    title = dr["FullName"].ToString(),
                                    subtitle = dr["Email"].ToString(),
                                    url = "ManageSellers.aspx?q=" + HttpUtility.UrlEncode(q)
                                });
                            }
                        }
                    }
                }

                context.Response.Write(new JavaScriptSerializer().Serialize(new { results }));
            }
            catch (Exception ex)
            {
                context.Response.Write(new JavaScriptSerializer().Serialize(new
                {
                    results = new object[0],
                    error = ex.Message
                }));
            }
        }

        public bool IsReusable { get { return false; } }
    }
}
