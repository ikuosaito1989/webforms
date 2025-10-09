using System;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e) { }

    protected void Btn_Click(object sender, EventArgs e)
    {
        Label1.Text = "PostBack OK: " + DateTime.Now.ToString("u");
    }
}
