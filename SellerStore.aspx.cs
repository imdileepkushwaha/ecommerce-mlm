using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class SellerStore : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string sellerIdStr = Request.QueryString["id"];
                int sellerId = 0;

                if (string.IsNullOrEmpty(sellerIdStr) || !int.TryParse(sellerIdStr, out sellerId))
                {
                    Response.Redirect("index.aspx");
                    return;
                }

                LoadSellerProfile(sellerId);
                LoadSellerCatalog(sellerId);
            }
        }

        private void LoadSellerProfile(int sellerId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string q = "SELECT * FROM SellerUsers WHERE Id = @sid AND IsActive = 1";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        SqlDataReader dr = cmd.ExecuteReader();
                        if (dr.Read())
                        {
                            string rawStoreName = dr["StoreName"] != DBNull.Value && !string.IsNullOrEmpty(dr["StoreName"].ToString()) 
                                ? dr["StoreName"].ToString() : dr["FullName"].ToString();

                            litStoreTitle.Text = rawStoreName;
                            litSectionTitle.Text = rawStoreName;

                            // Dynamic Location Resolution
                            string city = dr["City"] != DBNull.Value ? dr["City"].ToString().Trim() : "";
                            string state = dr["State"] != DBNull.Value ? dr["State"].ToString().Trim() : "";
                            string locationTxt = "India";
                            if (!string.IsNullOrEmpty(city) && !string.IsNullOrEmpty(state)) locationTxt = city + ", " + state;
                            else if (!string.IsNullOrEmpty(city)) locationTxt = city;
                            else if (!string.IsNullOrEmpty(state)) locationTxt = state;
                            litHeaderLocation.Text = locationTxt;

                            // Member Since processing
                            DateTime joinDate = dr["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(dr["CreatedAt"]) : DateTime.Now.AddMonths(-2);
                            litMemberSince.Text = joinDate.ToString("MMM yyyy");

                            // About the store text fallback
                            string customNote = dr["AdditionalNote"] != DBNull.Value ? dr["AdditionalNote"].ToString().Trim() : "";
                            litAboutStore.Text = !string.IsNullOrEmpty(customNote) 
                                ? customNote 
                                : "This seller offers premium quality products on our marketplace platform. Enjoy secure digital payments, 100% verified authentic items, and fast, trackable shipping options straight to your doorstep.";

                            // Visual Branding: Logo
                            string logoPath = dr["LogoPath"] != DBNull.Value ? dr["LogoPath"].ToString() : "";
                            if (!string.IsNullOrEmpty(logoPath))
                            {
                                imgStoreLogo.ImageUrl = NormalizePath(logoPath);
                                imgStoreLogo.Visible = true;
                                pnlInitialsAvatar.Visible = false;
                            }
                            else
                            {
                                // High end Initial fallback
                                litInitials.Text = GetInitials(rawStoreName);
                                imgStoreLogo.Visible = false;
                                pnlInitialsAvatar.Visible = true;
                            }

                            // Visual Branding: Banner
                            string bannerPath = dr["BannerPath"] != DBNull.Value ? dr["BannerPath"].ToString() : "";
                            if (!string.IsNullOrEmpty(bannerPath))
                            {
                                string bUrl = ResolveUrl(NormalizePath(bannerPath));
                                divHeroCover.Attributes["style"] = string.Format("background-image: url('{0}');", bUrl);
                            }
                            else
                            {
                                // CSS Gradient Pattern fallback for a high-premium aesthetics look
                                divHeroCover.Attributes["style"] = "background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%);";
                            }

                            // Store Meta contact mappings
                            litMetaEmail.Text = dr["Email"] != DBNull.Value ? dr["Email"].ToString() : "contact@seller.com";
                            string fullAddress = dr["Address"] != DBNull.Value ? dr["Address"].ToString() : locationTxt;
                            litMetaAddress.Text = fullAddress;
                            litMetaPin.Text = dr["Pincode"] != DBNull.Value ? dr["Pincode"].ToString() : "N/A";

                            // Parse Categories
                            string categoriesRaw = dr["RequestedCategories"] != DBNull.Value ? dr["RequestedCategories"].ToString() : "Fashion, Lifestyle, General";
                            var catList = categoriesRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                                        .Select(x => x.Trim()).ToList();
                            if (catList.Count == 0) catList.Add("Premium Seller");
                            rptSpecialities.DataSource = catList;
                            rptSpecialities.DataBind();
                        }
                        else
                        {
                            dr.Close();
                            Response.Redirect("index.aspx");
                        }
                        dr.Close();
                    }
                }
            }
            catch
            {
                Response.Redirect("index.aspx");
            }
        }

        private void LoadSellerCatalog(int sellerId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // Count products first
                    string countQ = "SELECT COUNT(1) FROM SellerProducts WHERE SellerId = @sid AND IsActive = 1";
                    using (SqlCommand cmdC = new SqlCommand(countQ, con))
                    {
                        cmdC.Parameters.AddWithValue("@sid", sellerId);
                        int count = Convert.ToInt32(cmdC.ExecuteScalar());
                        litStatProductCount.Text = count.ToString();
                    }

                    // Load Product Portfolio Repeater
                    string q = "SELECT TOP 24 * FROM SellerProducts WHERE SellerId = @sid AND IsActive = 1 ORDER BY CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptCatalog.DataSource = dt;
                            rptCatalog.DataBind();
                            rptCatalog.Visible = true;
                            pnlEmptyCatalog.Visible = false;
                        }
                        else
                        {
                            rptCatalog.Visible = false;
                            pnlEmptyCatalog.Visible = true;
                        }
                    }
                }
            }
            catch { }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "ST";
            string[] words = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length >= 2)
            {
                return (words[0][0].ToString() + words[1][0].ToString()).ToUpper();
            }
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        private string NormalizePath(string path)
        {
            if (string.IsNullOrEmpty(path)) return "";
            if (path.StartsWith("~/")) return path;
            if (path.StartsWith("/")) return "~" + path;
            return "~/" + path;
        }
    }
}
