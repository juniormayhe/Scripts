<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';

$nome=trim($_POST["nome"])."";
$nome=strip_tags($nome);
$email=trim($_POST["email"]);
$email=strip_tags($email);
$assunto=trim($_POST["assunto"]);
$assunto=strip_tags($assunto);
$mensagem=trim($_POST["mensagem"]);
$mensagem=strip_tags($mensagem);
$mensagem=htmlentities($mensagem);
$mensagem=preg_replace("/\r\n|\r|\n/",'<br/>',$mensagem);
$cidade=trim($_POST["cidade"]);
$cidade=strip_tags($cidade);
$telefone=trim($_POST["telefone"]);
$telefone=strip_tags($telefone);

$body = "<p>Esta mensagem foi enviada pelo Site name.</p><hr><p><b>Cliente:</b> " . htmlentities($nome) . "<br><b>Assunto:</b> " . htmlentities($assunto) . "<br><b>Email:</b> " . $email . "<br><b>Telefone:</b> " . $telefone . "<br><b>Cidade:</b> " . htmlentities($cidade) ."<br><b>Mensagem:</b><br>" . $mensagem . "</p>";
$googleRecaptchaSecret="*****";
$response=$_POST["captcha"];

$verify=file_get_contents("https://www.google.com/recaptcha/api/siteverify?secret={$googleRecaptchaSecret}&response={$response}");
$captcha_success=json_decode($verify);

if ($captcha_success->success==false) {
  //This user was not verified by recaptcha.
  echo("false");
}
else if ($captcha_success->success==true) {
  //This user is verified by recaptcha
  echo("true");

  $mail = new PHPMailer(true);                              // Passing `true` enables exceptions
  try {
      //Server settings
      $mail->SMTPDebug = 2;                                 // Enable verbose debug output
      $mail->isSMTP();                                      // Set mailer to use SMTP
      $mail->Host = 'smtp.server.com';  // Specify main and backup SMTP servers
      $mail->SMTPAuth = true;                               // Enable SMTP authentication
      $mail->Username = 'username@server.com';                 // SMTP username
      $mail->Password = '*******';                           // SMTP password
      $mail->SMTPSecure = 'ssl';                            // Enable TLS encryption, `ssl` also accepted
      $mail->Port = 465;                                    // TCP port to connect to

      //Recipients
      $mail->setFrom('username@server.com', 'Site name');
      $mail->addAddress('to@server.com', 'Name');     // Add a recipient
      $mail->addBCC('blindcopy@server.com', 'Bcc name');
      $mail->addReplyTo($email, '=?UTF-8?B?'.base64_encode($nome).'?=');
      
      //Content
      $mail->isHTML(true);                                  // Set email format to HTML
      if ($nome != "") {
        $mail->Subject = '=?UTF-8?B?'.base64_encode('Pedido de informação de ' . $nome) .'?=';
      }
      else {
        $mail->Subject = '=?UTF-8?B?'.base64_encode('Pedido de informação') .'?=';
      }
      $mail->Body    = $body;
      
      $mail->send();
      echo('Message has been sent');
  } catch (Exception $e) {
      echo('Message could not be sent.');//, $mail->ErrorInfo;
  }

}//success
?>
