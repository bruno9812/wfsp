#!/bin/bash

# Criando um arquivo temporário para o código PHP e estilo HTML
temp_file=$(mktemp)
cat <<'EOF' > "$temp_file"
<!DOCTYPE html>
<html>
<head>
    <title>Redes Wi-Fi Próximas</title>
    <style>
        body {
            background-color: #222;
            color: #fff;
            font-family: Arial, sans-serif;
        }

        .center-box {
            display: flex; /* Usando flexbox para centralizar o conteúdo */
            flex-direction: column; /* Alinhar os itens verticalmente */
            align-items: center; /* Centralizar horizontalmente */
            justify-content: center; /* Centralizar verticalmente */
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border-radius: 15px;
            background-color: #333;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.4);
        }
        
        .wifi-box {
            position: relative; /* Adicionando posicionamento relativo para que o botão absoluto seja posicionado em relação a esta caixa */
            list-style: none; /* Removendo o estilo de marcadores da lista */
            padding: 10px;
            width: 530px;
            border-radius: 10px;
            margin: 10px 0;
            background-color: #444;
        }

        .wifi-box span.label {
            color: #ccc;
        }

        .name {
            font-size: 18px;
            font-weight: bold;
        }

        .signal {
            font-size: 14px;
            color: #ccc; /* Mesma cor do rótulo */
        }

        #reload-button {
            position: absolute;
            top: 20px;
            left: 20px;
            padding: 8px 12px;
            border: none;
            border-radius: 5px;
            background-color: #4CAF50;
            color: #fff;
            cursor: pointer;
            font-size: 16px;
        }

        #reload-button:hover {
            background-color: #45a049;
        }

        .deauth-button {
            position: absolute; /* Adicionando posicionamento absoluto */
            top: 5px; /* Definindo a distância do topo */
            right: 5px; /* Definindo a distância da direita */
            padding: 5px 10px;
            border: none;
            border-radius: 5px;
            background-color: #FF0000;
            color: #fff;
            cursor: pointer;
            font-size: 14px;
        }

        .deauth-button:hover {
            background-color: #CC0000;
        }
    </style>
</head>
<body>
    <button id="reload-button" onclick="reloadWiFiList()">Recarregar</button>

    <div class="center-box">
        <h2>Redes Wi-Fi Próximas</h2>
        <ul id="wifi-list">
            <?php
                // Função para ler as redes Wi-Fi disponíveis usando nmcli
                function getNearbyWiFiNetworks() {
                    $output = array();
                    exec("nmcli -t -f SSID,FREQ,SIGNAL,BARS,SECURITY,ACTIVE,CHAN dev wifi list", $output);
                    return $output;
                }

                // Obter as redes Wi-Fi disponíveis
                $networks = getNearbyWiFiNetworks();

                // Exibir as redes Wi-Fi na lista
                foreach ($networks as $network) {
                    // Remover os cabeçalhos (--), se houver
                    $ssid = str_replace('--', '', $network);
                    // Remover espaços em branco no início e final do nome da rede
                    $ssid = trim($ssid);

                    if (!empty($ssid)) {
                        // Quebrar a linha em colunas
                        $columns = explode(':', $ssid);

                        // Extrair informações relevantes
                        $name = $columns[0];
                        $frequency = $columns[1];
                        $signal_strength = $columns[2];
                        $bars = $columns[3];
                        $security = $columns[4];
                        $channel = $columns[6]; // Extrair o número do canal

                        // Não exibir a informação de "Ativa"

                        // Exibir os detalhes da rede Wi-Fi
                        echo '<li class="wifi-box">';
                        echo '<span class="name">' . $name . '</span><br>'; // Nome da rede Wi-Fi
                        echo '<span class="label">Frequência:</span> ' . $frequency . '<br>'; // Frequência da rede Wi-Fi
                        echo '<span class="label">Sinal:</span> ' . $signal_strength . ' dBm (' . $bars . ' bars)</span><br>';
                        echo '<span class="label">Canal:</span> ' . $channel . '<br>';
                        echo '<span class="label">Segurança:</span> ' . $security . '<br>';
                        echo '<button class="deauth-button" onclick="deauthWiFi(\'' . $name . '\')">Deauth</button>';
                        echo '</li>';
                    }
                }
            ?>
        </ul>
    </div>

    <script>
        // Função para recarregar a lista de redes Wi-Fi
        function reloadWiFiList() {
            // Recarregar a página
            location.reload();
        }
    </script>
</body>
</html>
EOF

# Iniciando o servidor web embutido do PHP na porta 8000 e abrindo o navegador
php -S 0.0.0.0:8000 "$temp_file" &

# Abrindo o navegador em http://localhost:8000
xdg-open http://localhost:8000

# Aguardando a finalização do servidor (ou o usuário interromper com Ctrl+C)
wait
