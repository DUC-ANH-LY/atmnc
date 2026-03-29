<?php
// Minimal config for CVE-2019-10740 lab (Roundcube 1.3.9 + GreenMail).
// IMAP/SMTP hosts come from the Docker network.

$config = array();

$config['db_dsnw'] = 'sqlite:////var/roundcube/db/roundcube.sqlite?mode=0646';

$config['default_host'] = getenv('ROUNDCUBE_DEFAULT_HOST') ?: 'greenmail';
$config['default_port'] = (int) (getenv('ROUNDCUBE_DEFAULT_PORT') ?: 3143);

$config['smtp_host'] = getenv('ROUNDCUBE_SMTP_HOST') ?: 'greenmail';
$config['smtp_port'] = (int) (getenv('ROUNDCUBE_SMTP_PORT') ?: 3025);
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

$config['support_url'] = '';
$config['product_name'] = 'Roundcube 1.3.9 CVE-2019-10740 lab';
$config['des_key'] = 'rcmail-!24ByteDESkey*Str';
$config['plugins'] = array();
$config['enable_installer'] = false;
$config['mime_param_folding'] = 0;

// Plain IMAP to GreenMail (no TLS on lab ports).
$config['imap_conn_options'] = array(
    'ssl' => array('verify_peer' => false, 'verify_peer_name' => false),
);
