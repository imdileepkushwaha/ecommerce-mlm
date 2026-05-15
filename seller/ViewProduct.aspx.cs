using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerViewProduct : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Request.QueryString["id"] == null)
            {
                Response.Redirect("Products.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int productId = Convert.ToInt32(Request.QueryString["id"]);
                int sellerId = Convert.ToInt32(Session["SellerId"]);
                
                hlEditTop.NavigateUrl = "AddEditProduct.aspx?id=" + productId;
                LoadProductDetails(productId, sellerId);
            }
        }

        private void LoadProductDetails(int pid, int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Strict query bound to the authenticated Seller ID
                    string sql = "SELECT * FROM SellerProducts WHERE Id = @pid AND SellerId = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow r = dt.Rows[0];

                            // 1. Base Identity Block
                            litProductName.Text = r["Name"] != DBNull.Value ? r["Name"].ToString() : "Unnamed Product";
                            litSku.Text = r["Sku"] != DBNull.Value ? r["Sku"].ToString() : "N/A";
                            litBrand.Text = r["Brand"] != DBNull.Value && !string.IsNullOrEmpty(r["Brand"].ToString()) ? r["Brand"].ToString() : "Local Brand";
                            litCategory.Text = r["Category"] != DBNull.Value ? r["Category"].ToString() : "General";
                            litUpdatedAt.Text = r["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(r["UpdatedAt"]).ToString("dd MMM yyyy, hh:mm tt") : "Never";
                            litCreatedAt.Text = r["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(r["CreatedAt"]).ToString("dd MMM yyyy") : "Unknown";

                            // 2. Status Badge Evaluator
                            bool active = r["IsActive"] != DBNull.Value ? Convert.ToBoolean(r["IsActive"]) : false;
                            if (active)
                            {
                                litStatusBadge.Text = "<span class='badge-pill badge-pill-active'><i class='fas fa-globe'></i> Active on Storefront</span>";
                            }
                            else
                            {
                                litStatusBadge.Text = "<span class='badge-pill badge-pill-inactive'><i class='fas fa-eye-slash'></i> Deactivated (Locked)</span>";
                            }

                            // 3. Commercial Price Cards
                            decimal price = r["Price"] != DBNull.Value ? Convert.ToDecimal(r["Price"]) : 0;
                            decimal mrp = r["Mrp"] != DBNull.Value ? Convert.ToDecimal(r["Mrp"]) : 0;

                            litPrice.Text = price.ToString("N2");
                            litMrp.Text = mrp.ToString("N2");

                            if (mrp > price && mrp > 0)
                            {
                                decimal pct = Math.Round(((mrp - price) / mrp) * 100);
                                if (pct > 0)
                                {
                                    litDiscountPill.Text = string.Format("<div class='discount-pill-view'><i class='fas fa-tag u-mr-5'></i>{0}% DISCOUNT</div>", pct);
                                }
                            }

                            // 4. Smart Stock Reserve Banners
                            int stock = r["Stock"] != DBNull.Value ? Convert.ToInt32(r["Stock"]) : 0;
                            if (stock <= 0)
                            {
                                litStockIcon.Text = "<i class='fas fa-circle-exclamation' style='color:#ef4444;'></i>";
                                litStockStatus.Text = "<span style='color:#ef4444;'>Out of Stock / Sold Out</span>";
                            }
                            else if (stock < 10)
                            {
                                litStockIcon.Text = "<i class='fas fa-triangle-exclamation' style='color:#f59e0b;'></i>";
                                litStockStatus.Text = string.Format("<span style='color:#f59e0b;'>Low Reserves Warning ({0} units left)</span>", stock);
                            }
                            else
                            {
                                litStockIcon.Text = "<i class='fas fa-circle-check' style='color:#10b981;'></i>";
                                litStockStatus.Text = string.Format("<span style='color:#10b981;'>Nominal Reserves Available ({0} units)</span>", stock);
                            }

                            // 5. Structural Descriptive Blocks
                            litDesc.Text = r["Description"] != DBNull.Value && !string.IsNullOrEmpty(r["Description"].ToString()) 
                                           ? HttpUtility.HtmlDecode(r["Description"].ToString()).Replace("\n", "<br/>")
                                           : "<em style='color:#94a3b8;'>No descriptive public narrative indexed for this inventory record.</em>";

                            litProductType.Text = r["ProductType"] != DBNull.Value && !string.IsNullOrEmpty(r["ProductType"].ToString()) ? r["ProductType"].ToString() : "Standard Simple";
                            litGender.Text = r["Gender"] != DBNull.Value && !string.IsNullOrEmpty(r["Gender"].ToString()) ? r["Gender"].ToString() : "Universal / Unisex";
                            litWeight.Text = r["Weight"] != DBNull.Value && !string.IsNullOrEmpty(r["Weight"].ToString()) ? r["Weight"].ToString() : "N/A";
                            litDimensions.Text = r["Dimensions"] != DBNull.Value && !string.IsNullOrEmpty(r["Dimensions"].ToString()) ? r["Dimensions"].ToString() : "N/A";
                            litShipping.Text = r["ShippingClass"] != DBNull.Value && !string.IsNullOrEmpty(r["ShippingClass"].ToString()) ? r["ShippingClass"].ToString() : "Global Default Standard";

                            // 6. SEO Metadata Stream
                            litMetaTitle.Text = r["MetaTitle"] != DBNull.Value && !string.IsNullOrEmpty(r["MetaTitle"].ToString()) ? r["MetaTitle"].ToString() : "Default Catalog Headline Auto-generated";
                            litMetaDesc.Text = r["MetaDescription"] != DBNull.Value && !string.IsNullOrEmpty(r["MetaDescription"].ToString()) ? r["MetaDescription"].ToString() : "No custom indexing snippet provided.";
                            
                            if (r["MetaKeywords"] != DBNull.Value && !string.IsNullOrEmpty(r["MetaKeywords"].ToString()))
                            {
                                string[] keywords = r["MetaKeywords"].ToString().Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                                if (keywords.Length > 0)
                                {
                                    litMetaKeywords.Text = string.Join("", keywords.Select(k => string.Format("<span class='attrib-tag-pill'>{0}</span>", k.Trim())));
                                }
                            }

                            // 7. Dual Attribute Repeater Arrays (Colors & Sizes)
                            BindAttributeRepeater(r["ColorOptions"], rptColors, phColors);
                            BindAttributeRepeater(r["SizeOptions"], rptSizes, phSizes);

                            // 8. Advanced Imagery Light-Gallery Array Assembler
                            BuildImageGallery(r["MainImage"], r["ThumbnailUrl"], r["GalleryUrls"]);
                        }
                        else
                        {
                            // Cross-access denial or non-existent
                            Response.Redirect("Products.aspx");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                litProductName.Text = "Telemetry Retrieval Fault: " + ex.Message;
            }
        }

        private void BindAttributeRepeater(object dbVal, Repeater rpt, PlaceHolder ph)
        {
            if (dbVal != DBNull.Value && !string.IsNullOrEmpty(dbVal.ToString()))
            {
                string[] items = dbVal.ToString().Split(new[] { ',', '|', ';' }, StringSplitOptions.RemoveEmptyEntries);
                var cleanItems = items.Select(x => x.Trim()).Where(x => !string.IsNullOrEmpty(x)).ToList();
                
                if (cleanItems.Count > 0)
                {
                    rpt.DataSource = cleanItems;
                    rpt.DataBind();
                    ph.Visible = true;
                }
            }
        }

        private void BuildImageGallery(object mainImg, object thumbImg, object galleryStr)
        {
            List<string> resolvedPaths = new List<string>();

            // Normalize paths helper
            Action<object> tryAddPath = (obj) => {
                if (obj != DBNull.Value && !string.IsNullOrEmpty(obj.ToString()))
                {
                    string path = obj.ToString();
                    string cleanPath = path.StartsWith("~") ? path.Substring(1) : path;
                    if (!cleanPath.StartsWith("/")) cleanPath = "/" + cleanPath;
                    if (!resolvedPaths.Contains(cleanPath))
                    {
                        resolvedPaths.Add(cleanPath);
                    }
                }
            };

            // Stage 1: Collect Candidate Images
            tryAddPath(mainImg);
            tryAddPath(thumbImg);

            if (galleryStr != DBNull.Value && !string.IsNullOrEmpty(galleryStr.ToString()))
            {
                string[] extraPaths = galleryStr.ToString().Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var p in extraPaths)
                {
                    tryAddPath(p.Trim());
                }
            }

            // Stage 2: Final Layout Binding
            if (resolvedPaths.Count > 0)
            {
                heroImg.ImageUrl = resolvedPaths[0];
                heroImg.Visible = true;
                litHeroPlaceholder.Visible = false;

                rptThumbs.DataSource = resolvedPaths;
                rptThumbs.DataBind();
            }
            else
            {
                heroImg.Visible = false;
                litHeroPlaceholder.Visible = true;
                rptThumbs.DataSource = null;
                rptThumbs.DataBind();
            }
        }
    }
}
