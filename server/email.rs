use actix_web::client::{Client, ClientRequest};
use serde::{Serialize};

#[derive(Serialize, Clone)]
pub struct Email {
    pub from: String,
    pub to: String,
    pub subject: String,
    pub text: String,
    pub html: String,
}

pub fn create_email(confirmation_url: String, mail_domain: String, recipient: String, invitation: String) -> Email {
    let link: String = format!("{}/{}", confirmation_url, invitation);
    Email { 
        from: format!("Admin <confirmation@{}>", mail_domain),
        to: recipient,
        subject: "Please verify your account".to_string(),
        text: format!("Hi,\nThanks for signing up! Please confirm your email address by clicking on the link below.\n\n{}\n\nIf you did not sign up for an account, please disregard this email.", link),
        html: format!("<!doctype html><html><head><title>Confirmation</title></head><body><p>Hi,<p>Thanks for signing up! Please confirm your email address by clicking on the link below.<p><a href=\"{}\">{}</a><p>If you did not sign up for an account, please disregard this email.</body></html>", link, link)
    }
}

pub async fn send_verification_email(c: ClientRequest, email: Email) -> Result<String, String> {
    
    let sent = c.send_form(&email).await;
    println!("{:?}", sent);
    match sent {
        Ok(response) => if response.status().is_success() {Ok("success".to_string())} else {Err("failed".to_string())},
        Err(e) => Err(e.to_string())
    }
}

pub fn create_mail_client(key: String, mail_domain: String) -> ClientRequest {
    Client::build()
        .basic_auth("api", Some(&key))
        .disable_timeout()
        .finish()
        .post(format!("https://api.mailgun.net/v3/{}/messages", mail_domain))
}