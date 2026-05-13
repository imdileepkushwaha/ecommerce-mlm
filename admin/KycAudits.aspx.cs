using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class KycAudits : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPendingKyc();
            }
        }

        private void LoadPendingKyc()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // Load all sellers awaiting manual KYC clearance, access requests or re-audits, prioritizing earliest updates
                    string query = "SELECT * FROM SellerUsers WHERE KycStatus = 'Pending' OR EditRequestStatus IN ('PendingApproval', 'DraftSubmitted') ORDER BY UpdatedAt ASC";


                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptKyc.DataSource = dt;
                            rptKyc.DataBind();
                            phEmptyState.Visible = false;
                        }
                        else
                        {
                            rptKyc.DataSource = null;
                            rptKyc.DataBind();
                            phEmptyState.Visible = true;
                        }

                        lblCount.Text = dt.Rows.Count + " Pending";
                    }
                }
            }
            catch (Exception ex)
            {
                lblCount.Text = "System Error: " + ex.Message;
            }
        }

        protected string GetQueueBadge(object kycStatus, object editRequestStatus)
        {
            string ks = kycStatus != DBNull.Value ? kycStatus.ToString() : "";
            string es = editRequestStatus != DBNull.Value ? editRequestStatus.ToString() : "";

            if (es.Equals("PendingApproval", StringComparison.OrdinalIgnoreCase))
            {
                return "<span class='badge' style='background:#eff6ff; color:#2563eb; border:1px solid #bfdbfe; margin-top:5px;'><i class='fas fa-lock-open u-mr-5'></i> Edit Access Req</span>";
            }
            else if (es.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase))
            {
                return "<span class='badge' style='background:#fef3c7; color:#d97706; border:1px solid #fde68a; margin-top:5px;'><i class='fas fa-pen-to-square u-mr-5'></i> Re-audit Pending</span>";
            }
            else if (ks.Equals("Pending", StringComparison.OrdinalIgnoreCase))
            {
                return "<span class='badge' style='background:#fef2f2; color:#ef4444; border:1px solid #fecaca; margin-top:5px;'><i class='fas fa-clock u-mr-5'></i> New Awaiting Review</span>";
            }

            return "<span class='badge badge-warning u-mt-5'>In Review</span>";
        }
    }
}

