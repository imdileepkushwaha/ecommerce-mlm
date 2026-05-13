using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageOrders : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOrders();
            }
        }

        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "UpdateStatus")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                if (args.Length == 2)
                {
                    string oid = args[0];
                    string newStat = args[1];
                    
                    try {
                        using (SqlConnection con = new SqlConnection(strcon)) {
                            con.Open();
                            string sql = "UPDATE Orders SET Status = @stat, UpdatedAt = GETDATE() WHERE Id = @id";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@stat", newStat);
                            cmd.Parameters.AddWithValue("@id", oid);
                            cmd.ExecuteNonQuery();
                        }
                        Response.Redirect("ManageOrders.aspx"); // Prevent double-trigger
                    } catch { }
                }
            }
        }

        private void LoadOrders()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string sql = @"SELECT O.Id, O.TotalAmount, O.ItemCount, O.Status, O.CreatedAt, O.PaymentMode, O.OrderRef, U.FullName, U.Email 
                                   FROM Orders O 
                                   INNER JOIN Users U ON O.UserId = U.Id 
                                   ORDER BY O.CreatedAt DESC";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptOrders.DataSource = dt;
                        rptOrders.DataBind();
                        rptOrders.Visible = true;
                        pnlEmpty.Visible = false;
                        lblCount.Text = "Volume: " + dt.Rows.Count;
                    }
                    else
                    {
                        rptOrders.Visible = false;
                        pnlEmpty.Visible = true;
                        lblCount.Text = "No Orders";
                    }
                }
            }
            catch
            {
                lblCount.Text = "System Error";
            }
        }

        // Status badge color logic helper
        protected string GetStatusClass(object status)
        {
            if (status == null || status == DBNull.Value) return "badge-danger";
            string s = status.ToString().ToLower();
            if (s == "delivered" || s == "completed" || s == "success") return "badge-success";
            if (s == "shipped" || s == "dispatched" || s == "processing") return "badge-warning";
            if (s == "pending") return "badge-pending";
            return "badge-danger";
        }
    }
}
