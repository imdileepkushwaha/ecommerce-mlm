using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerManageReviews : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindReviews();
            }
        }

        private void BindReviews()
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // Hydrate statistical metrics in the same pipeline execution context
                    LoadReviewStats(sid, con);

                    // Select reviews exclusively mapped to the specific merchant, clustering Pending actions at the top
                    string sql = @"
                        SELECT 
                            PR.Id,
                            PR.ProductId,
                            PR.ReviewerName,
                            PR.Rating,
                            PR.ReviewText,
                            PR.ReviewDate,
                            PR.ReviewStatus,
                            PR.IsVerifiedPurchase,
                            SP.MainImage,
                            SP.Name AS ProductName
                        FROM ProductReviews PR
                        INNER JOIN SellerProducts SP ON PR.ProductId = SP.Id
                        WHERE SP.SellerId = @sid
                        ORDER BY CASE WHEN UPPER(PR.ReviewStatus) = 'PENDING' THEN 0 ELSE 1 END ASC, PR.ReviewDate DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptReviews.DataSource = dt;
                            rptReviews.DataBind();
                            rptReviews.Visible = true;
                            phEmptyState.Visible = false;
                        }
                        else
                        {
                            rptReviews.DataSource = null;
                            rptReviews.DataBind();
                            rptReviews.Visible = false;
                            phEmptyState.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Query Stream Aborted: " + ex.Message, true);
            }
        }

        private void LoadReviewStats(int sid, SqlConnection con)
        {
            try
            {
                string sqlStats = @"
                    SELECT 
                        COUNT(1) AS TotalCount,
                        SUM(CASE WHEN UPPER(ReviewStatus) = 'PENDING' THEN 1 ELSE 0 END) AS PendingCount,
                        SUM(CASE WHEN UPPER(ReviewStatus) = 'APPROVED' THEN 1 ELSE 0 END) AS PublicCount,
                        AVG(CAST(Rating AS DECIMAL(5,2))) AS AvgRating
                    FROM ProductReviews PR
                    INNER JOIN SellerProducts SP ON PR.ProductId = SP.Id
                    WHERE SP.SellerId = @sid";

                using (SqlCommand cmdStats = new SqlCommand(sqlStats, con))
                {
                    cmdStats.Parameters.AddWithValue("@sid", sid);
                    using (SqlDataReader dr = cmdStats.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            int total = dr["TotalCount"] != DBNull.Value ? Convert.ToInt32(dr["TotalCount"]) : 0;
                            int pending = dr["PendingCount"] != DBNull.Value ? Convert.ToInt32(dr["PendingCount"]) : 0;
                            int approved = dr["PublicCount"] != DBNull.Value ? Convert.ToInt32(dr["PublicCount"]) : 0;
                            decimal avgRating = dr["AvgRating"] != DBNull.Value ? Convert.ToDecimal(dr["AvgRating"]) : 0.0m;

                            litTotalReviews.Text = total.ToString();
                            litPendingReviews.Text = pending.ToString();
                            litApprovedReviews.Text = approved.ToString();
                            litAvgRating.Text = avgRating > 0 ? avgRating.ToString("0.0") : "0.0";
                        }
                    }
                }
            }
            catch (Exception ex) 
            { 
                // Defensive: Fallback gracefully so main query is not obstructed
                litTotalReviews.Text = "0";
                litPendingReviews.Text = "0";
                litApprovedReviews.Text = "0";
                litAvgRating.Text = "0.0";
            }
        }

        protected void rptReviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);
            int reviewId = Convert.ToInt32(e.CommandArgument);

            string targetStatus = "";
            int isApprovedInt = 0;
            string actionWord = "";

            if (e.CommandName == "ApproveReview")
            {
                targetStatus = "APPROVED";
                isApprovedInt = 1;
                actionWord = "approved & authorized";
            }
            else if (e.CommandName == "RejectReview")
            {
                targetStatus = "REJECTED";
                isApprovedInt = 0;
                actionWord = "rejected & masked";
            }
            else
            {
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Update and protect scoped mutation: ensuring review belongs strictly to a product registered to this seller
                    string sql = @"
                        UPDATE ProductReviews 
                        SET IsApproved = @app, ReviewStatus = @stat
                        WHERE Id = @rid AND ProductId IN (SELECT Id FROM SellerProducts WHERE SellerId = @sid)";
                    
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@app", isApprovedInt);
                        cmd.Parameters.AddWithValue("@stat", targetStatus);
                        cmd.Parameters.AddWithValue("@rid", reviewId);
                        cmd.Parameters.AddWithValue("@sid", sid);
                        int count = cmd.ExecuteNonQuery();

                        if (count > 0)
                        {
                            ShowMsg("✨ Feedback has been successfully " + actionWord + ".", false);
                        }
                        else
                        {
                            ShowMsg("Authorization Error: Could not update verification state.", true);
                        }
                    }
                }
                BindReviews(); // Instant Grid Synchronous Refresh
            }
            catch (Exception ex)
            {
                ShowMsg("State Transition Interrupted: " + ex.Message, true);
            }
        }

        #region Visual Formatters

        protected string GetProductImage(object mainImage)
        {
            string path = mainImage != DBNull.Value ? mainImage.ToString() : "";
            if (string.IsNullOrEmpty(path))
            {
                return "<i class='fas fa-image' style='color:#cbd5e1; font-size:1.2rem;'></i>";
            }

            if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
                path.StartsWith("https://", StringComparison.OrdinalIgnoreCase) || 
                path.StartsWith("//"))
            {
                return string.Format("<img src='{0}' style='width:100%; height:100%; object-fit:cover; border-radius:6px;' alt='thumb' />", path);
            }

            string cleanPath = path.StartsWith("~") ? path.Substring(1) : path;
            if (!cleanPath.StartsWith("/")) cleanPath = "/" + cleanPath;
            return string.Format("<img src='{0}' style='width:100%; height:100%; object-fit:cover; border-radius:6px;' alt='thumb' />", cleanPath);
        }

        protected string GetStarsHTML(object ratingObj)
        {
            int rating = ratingObj != DBNull.Value ? Convert.ToInt32(ratingObj) : 5;
            StringBuilder sb = new StringBuilder();
            for (int i = 1; i <= 5; i++)
            {
                if (i <= rating) sb.Append("<i class='fas fa-star'></i>");
                else sb.Append("<i class='far fa-star' style='color:#e2e8f0;'></i>");
            }
            return sb.ToString();
        }

        protected string GetStatusBadge(object statVal)
        {
            string status = statVal != DBNull.Value ? statVal.ToString().ToUpper() : "PENDING";
            if (status == "APPROVED")
            {
                return "<span class='badge-pill badge-pill-active' style='background: #ecfdf5; color: #059669; border: 1px solid #bbf7d0;'><i class='fas fa-circle-check'></i> Public</span>";
            }
            else if (status == "REJECTED")
            {
                return "<span class='badge-pill badge-pill-inactive' style='background: #fef2f2; color: #dc2626; border: 1px solid #fecaca;'><i class='fas fa-circle-xmark'></i> Masked</span>";
            }
            else
            {
                return "<span class='badge-pill' style='background: #fffbeb; color: #d97706; border: 1px solid #fde68a;'><i class='fas fa-clock'></i> Pending</span>";
            }
        }

        #endregion

        private void ShowMsg(string msg, bool isError)
        {
            lblGlobalMsg.Text = msg;
            lblGlobalMsg.Visible = true;
            
            if (isError)
            {
                lblGlobalMsg.BackColor = System.Drawing.Color.FromName("#fef2f2");
                lblGlobalMsg.ForeColor = System.Drawing.Color.FromName("#dc2626");
                lblGlobalMsg.Style["border"] = "1px solid #fecaca";
            }
            else
            {
                lblGlobalMsg.BackColor = System.Drawing.Color.FromName("#f0fdf4");
                lblGlobalMsg.ForeColor = System.Drawing.Color.FromName("#16a34a");
                lblGlobalMsg.Style["border"] = "1px solid #bbf7d0";
            }
            
            upnlMsg.Update();
        }
    }
}
