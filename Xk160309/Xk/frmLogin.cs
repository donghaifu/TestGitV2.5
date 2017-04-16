﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Xk
{
    public partial class frmLogin : Form
    {
        public frmLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (cbIsManager.Checked)
            {
                CPublic.CheckUsers(txtID.Text, txtPwd.Text);
            }
            else
            {
                CPublic.CheckIp();
            }

            if (CPublic.isUser == false)
                MessageBox.Show("密码错误！", "登录", MessageBoxButtons.OK, MessageBoxIcon.Information);
            else
                Close();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}