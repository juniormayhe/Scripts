<?php
require 'PHPMailerAutoload.php';
$mail = new PHPMailer();
$mail->IsSMTP();
$mail->CharSet = 'UTF-8';

$mail->Host       = "mail.ibp.org.br"; // SMTP server example
$mail->SMTPDebug  = 0;                     // enables SMTP debug information (for testing)
$mail->SMTPAuth   = true;                  // enable SMTP authentication
$mail->SMTPSecure = 'tls'; 
$mail->Port       = 993;                    // set the SMTP port for the GMAIL server
$mail->Username   = "ti"; // SMTP account username example
$mail->Password   = "ibp!@#2532";        // SMTP account password example
$mail->isHTML(true);
$mail->Subject = "Assunto do email";
$mail->Body = "<i>Teste em PHP</i>";
$mail->AltBody = "Teste em PHP";

$mail->setFrom("from@youremail.com", "TI IBP");
$mail->addAddress("to@domain.com", "Username");
if(!$mail->send()) 
{
    echo "Could not send  email: " . $mail->ErrorInfo;
} 
else 
{
    echo "Email sent";
}
?>