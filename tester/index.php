<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="x-ua-compatible" content="ie=edge">
        <title>Simple PHP App</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style type="text/css">.display-3{font-size:4.5rem;font-weight:300}.lead{font-size:1.25rem;font-weight:300}</style>
    </head>
    <body>
        <div class="center">
            <h1 class="display-3">Hello, PHP!</h1>
            <p class="lead">Your PHP application is now running on the host <code><?php echo gethostname(); ?></code>.</p>
            <p>This host is running PHP version <code><?php echo phpversion(); ?></code>.</p>
        </div>
        <hr />
        <?php $stdout = fopen("php://stdout", "w"); fputs($stdout, "This is a stdout message"); ?>
        <?php $stderr = fopen("php://stderr", "w"); fputs($stderr, "This is a stdout message"); ?>
        <?php $logStream = fopen(getenv("PHP_LOG_STREAM"), "w"); fprintf($logStream, "%s\n", "This is a log stream message"); ?>
        <div class="phpinfo">
            <?php phpinfo(); ?>
        </div>
    </body>
</html>
