using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageProducts : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProducts();
            }
        }

        protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                string pid = e.CommandArgument.ToString();
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        // Integrous Sync: Toggling Active state to True on a Pending item triggers an instant ListingStatus='Approved'
                        string sql = @"UPDATE SellerProducts 
                                       SET IsActive = ~IsActive, 
                                           ListingStatus = CASE WHEN IsActive = 0 AND (ListingStatus = 'Pending' OR ListingStatus IS NULL) THEN 'Approved' ELSE ListingStatus END,
                                           UpdatedAt = GETDATE()
                                       WHERE Id = @pid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.ExecuteNonQuery();
                    }
                    Response.Redirect("ManageProducts.aspx"); // Purge postback state to prevent re-toggle on refresh
                }
                catch (Exception ex) { }
            }
            else if (e.CommandName == "ApproveProduct")
            {
                string pid = e.CommandArgument.ToString();
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        // Explicit Core Approval Path: Forcibly activates product and guarantees full Approved listing status.
                        string sql = "UPDATE SellerProducts SET ListingStatus = 'Approved', IsActive = 1, UpdatedAt = GETDATE() WHERE Id = @pid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.ExecuteNonQuery();
                    }
                    Response.Redirect("ManageProducts.aspx"); // Smooth state cycle
                }
                catch (Exception ex) { }
            }
        }

        private void LoadProducts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string sql = @"SELECT p.Id, p.Name, p.Brand, p.Category, p.Price, p.Mrp, p.Stock, p.MainImage, p.IsActive, p.CreatedAt, p.Slug, p.ListingStatus, s.FullName AS SellerName 
                                   FROM SellerProducts p
                                   LEFT JOIN SellerUsers s ON p.SellerId = s.Id
                                   ORDER BY p.CreatedAt DESC";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptProducts.DataSource = dt;
                        rptProducts.DataBind();
                        rptProducts.Visible = true;
                        pnlEmpty.Visible = false;
                        lblCount.Text = "Count: " + dt.Rows.Count;
                    }
                    else
                    {
                        rptProducts.Visible = false;
                        pnlEmpty.Visible = true;
                        lblCount.Text = "0 Total";
                    }
                }
            }
            catch (Exception ex)
            {
                lblCount.Text = "ERR";
            }
        }

        #region Status Visual Handlers
        protected string GetListingStatusBadge(object dbStatus, object dbIsActive)
        {
            string status = dbStatus != null && dbStatus != DBNull.Value ? dbStatus.ToString().Trim() : "Pending";
            bool isActive = dbIsActive != null && dbIsActive != DBNull.Value ? Convert.ToBoolean(dbIsActive) : false;

            if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
            {
                return "<span class='badge badge-pending'><i class='fas fa-clock u-mr-5'></i>Pending Review</span>";
            }
            else if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase) || status.Equals("Active", StringComparison.OrdinalIgnoreCase))
            {
                if (isActive)
                {
                    return "<span class='badge badge-success'><i class='fas fa-circle-check u-mr-5'></i>Approved</span>";
                }
                else
                {
                    return "<span class='badge' style='background:#e2e8f0; color:#475569; font-weight:700;'><i class='fas fa-eye-slash u-mr-5'></i>Suspended</span>";
                }
            }
            else
            {
                return "<span class='badge badge-danger'><i class='fas fa-circle-xmark u-mr-5'></i>" + status + "</span>";
            }
        }
        #endregion
    }
}
