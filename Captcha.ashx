<%@ WebHandler Language="C#" Class="ecommerce_mlm.Captcha" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.IO;

namespace ecommerce_mlm
{
    public class Captcha : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            // 1. Generate random text
            string captchaText = GenerateRandomText(5);
            
            // Store in Session for verification later
            context.Session["CaptchaCode"] = captchaText;

            // 2. Generate Image
            using (Bitmap bmp = new Bitmap(150, 50))
            {
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    g.SmoothingMode = SmoothingMode.AntiAlias;
                    g.Clear(Color.FromArgb(243, 244, 246)); // Auth gray bg
                    
                    // Add some noise lines
                    Random rnd = new Random();
                    for(int i=0; i<5; i++) {
                        Pen p = new Pen(Color.FromArgb(rnd.Next(150,255), rnd.Next(150,255), rnd.Next(150,255)), 1);
                        g.DrawLine(p, rnd.Next(0, 150), rnd.Next(0, 50), rnd.Next(0, 150), rnd.Next(0, 50));
                    }

                    // Draw Text
                    Rectangle rect = new Rectangle(0, 0, 150, 50);
                    HatchBrush brush = new HatchBrush(HatchStyle.Wave, Color.Black, Color.FromArgb(31, 41, 55));
                    
                    // Font
                    Font font = new Font("Arial", 22, FontStyle.Bold | FontStyle.Italic);
                    
                    // Centering the text
                    StringFormat sf = new StringFormat();
                    sf.Alignment = StringAlignment.Center;
                    sf.LineAlignment = StringAlignment.Center;
                    
                    g.DrawString(captchaText, font, brush, rect, sf);
                    
                    // Output the image
                    context.Response.ContentType = "image/png";
                    using (MemoryStream ms = new MemoryStream())
                    {
                        bmp.Save(ms, ImageFormat.Png);
                        ms.WriteTo(context.Response.OutputStream);
                    }
                }
            }
        }

        private string GenerateRandomText(int length)
        {
            string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // Excluded similar looking ones
            char[] result = new char[length];
            Random random = new Random();
            for (int i = 0; i < length; i++)
            {
                result[i] = chars[random.Next(chars.Length)];
            }
            return new string(result);
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
