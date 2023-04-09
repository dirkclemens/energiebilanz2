<?php
    # Obtain the JSON payload from POSTed via HTTP
    
    ini_set('date.timezone','Europe/Berlin');
    // ini_set('display_errors','On');
    // error_reporting(E_STRICT);
    // error_reporting(E_ALL & ~E_NOTICE);
    error_reporting(E_ALL);

    header("Content-type: text/plain");

    $request = explode('/', trim($_SERVER['QUERY_STRING'],'/'));

    $range = "today";
    $limit = 12;
    foreach ($_GET as $key=>$value) {
        // echo "$key = " . urldecode($value) . "\n";
        if ($key == "range") $range = $value;
        if ($key == "limit") $limit = $value;
    }

    $smarthomedb = '/../smarthome.db';

    $response = "";

    function getSQL($sql){
        global $smarthomedb;
        // connect to the sqlite database
        $db = new SQLite3($smarthomedb);
    
        $results = $db->query($sql);
        $rows = array();
        while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
            array_push($rows, $row);
        }
        print json_encode($rows);
        return $results;
    }    

    $today = date("Y-m-d");
    // print($today);
    switch ($range) {
        case 'week':
            $sql = 'SELECT abs(random()) AS id, substr(TIMESTAMP, 0, 11) AS DT, DAILY AS PV FROM "V_PIKO42_DAILY" ORDER BY TIMESTAMP DESC LIMIT '.$limit.';';
            break;
        case 'month':
                $sql = 'SELECT abs(random()) AS id, TIMESTAMP AS DT, MONTH AS PV FROM "PIKO42_MONTH" ORDER BY TIMESTAMP DESC LIMIT '.$limit.';';
            break;
        case 'year':
            $sql = 'SELECT abs(random()) AS id, TIMESTAMP AS DT, YEAR AS PV FROM "PIKO42_YEAR" ORDER BY TIMESTAMP DESC LIMIT '.$limit.';';
            break;        
        default:
            $sql = 'SELECT abs(random()) AS id, TIMESTAMP AS DT, CURRENT AS PV FROM "PIKO42" WHERE "TIMESTAMP" LIKE "%'.$today.'%" ORDER BY "TIMESTAMP" ASC;';
            break;
    }
    // print ($sql);

    $response = getSQL($sql);
    print ($response);

    $response_code = 200;
    http_response_code($response_code);

?>