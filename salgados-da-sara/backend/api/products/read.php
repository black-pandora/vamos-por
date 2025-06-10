<?php
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    include_once '../../config/database.php';
    include_once '../../models/Product.php';

    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception('Erro de conexão com banco de dados');
    }

    $product = new Product($db);

    $stmt = $product->readAll();
    $num = $stmt->rowCount();

    if($num > 0) {
        $products_arr = array();
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            
            $product_item = array(
                "id" => $id,
                "nome" => $nome,
                "preco" => floatval($preco),
                "categoria" => $categoria,
                "descricao" => $descricao,
                "eh_porcionado" => $eh_porcionado,
                "eh_personalizado" => $eh_personalizado,
                "criado_em" => $criado_em
            );
            
            array_push($products_arr, $product_item);
        }
        
        http_response_code(200);
        echo json_encode(array(
            "sucesso" => true,
            "dados" => $products_arr
        ));
    } else {
        http_response_code(200);
        echo json_encode(array(
            "sucesso" => true,
            "dados" => array()
        ));
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'sucesso' => false,
        'mensagem' => 'Erro interno: ' . $e->getMessage()
    ]);
}
?>