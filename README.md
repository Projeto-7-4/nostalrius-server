# Nostalrius 7.72 - OT Server

![Tibia 7.72](https://img.shields.io/badge/Tibia-7.72-blue)
![License](https://img.shields.io/badge/license-GPL%202.0-green)

## 📖 Sobre

Servidor de Tibia 7.72 baseado no **Nostalrius**, totalmente funcional e otimizado para a experiência clássica do Tibia.

## ✨ Características

- **Protocolo 7.72** - Cliente clássico do Tibia
- **Sistema de Save Otimizado** - Posição e itens salvos corretamente
- **Sistema AFK Inteligente** - 30 minutos de idle antes do kick
- **Timeouts Configuráveis** - Sem desconexões inesperadas
- **SQL Completo** - Schema do banco de dados incluído
- **Compatível com MySQL 5.7+**

## 🚀 Instalação

### Requisitos

- Ubuntu 20.04+ (ou Linux similar)
- MySQL 5.7+
- CMake 3.5+
- GCC 9+
- LuaJIT 5.1
- Boost 1.66+

### Dependências (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y build-essential cmake git libboost-all-dev \
    libluajit-5.1-dev libmysqlclient-dev mysql-server \
    libpugixml-dev libcrypto++-dev libgmp3-dev
```

### Compilação

```bash
# Clone o repositório
git clone https://github.com/DigitalSolutions-999/canary.git nostalrius
cd nostalrius

# Crie a pasta de build
mkdir build && cd build

# Configure e compile
cmake ..
make -j$(nproc)
```

### Configuração do Banco de Dados

```bash
# Crie o banco de dados
mysql -u root -p
CREATE DATABASE nostalrius;
CREATE USER 'otserver'@'localhost' IDENTIFIED BY 'sua_senha_aqui';
GRANT ALL PRIVILEGES ON nostalrius.* TO 'otserver'@'localhost';
FLUSH PRIVILEGES;
exit;

# Importe o schema
mysql -u otserver -p nostalrius < nostalrius.sql
```

### Configuração do Servidor

Edite o arquivo `config.lua`:

```lua
-- IP do servidor
ip = "127.0.0.1"

-- Porta do servidor
loginProtocolPort = 7171
gameProtocolPort = 7172

-- Configurações do MySQL
mysqlHost = "localhost"
mysqlUser = "otserver"
mysqlPass = "sua_senha_aqui"
mysqlDatabase = "nostalrius"
mysqlPort = 3306
mysqlSock = "/var/run/mysqld/mysqld.sock"

-- Tempo de AFK (30 minutos)
kickIdlePlayerAfterMinutes = 30
```

### Executando o Servidor

```bash
cd ~/nostalrius
./build/tfs
```

## 🎮 Cliente

Este servidor é compatível com o **OTClient mehah** (versão Nekiro/Nostalrius).

- [OTClient mehah - Nekiro/Nostalrius](https://github.com/mehah/otclient)

### Configuração do Cliente

No arquivo `init.lua` do OTClient:

```lua
Servers = {
    ["Nostalrius 7.72"] = "SEU_IP:7171:772"
}
```

Certifique-se de ter os assets corretos em `data/things/772/`:
- `Tibia.dat`
- `Tibia.spr`

## 🌐 Website (MyAAC)

O servidor é compatível com **MyAAC** para gestão de contas e guild.

### Instalação do MyAAC

```bash
# Clone o MyAAC
cd /var/www/html
git clone https://github.com/slawkens/myaac.git .

# Configure as permissões
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Instale as dependências
composer install
npm install
```

### Configuração do MyAAC

Edite `config.local.php`:

```php
$config['server_path'] = '/caminho/para/nostalrius/';
$config['client'] = 772;
$config['database_host'] = 'localhost';
$config['database_user'] = 'otserver';
$config['database_password'] = 'sua_senha_aqui';
$config['database_name'] = 'nostalrius';
$config['database_socket'] = '/var/run/mysqld/mysqld.sock';
```

## 📝 Correções Implementadas

### ✅ Sistema de Save de Posição
- Corrigido bug do campo `sex` na query SQL
- Posição do jogador agora salva corretamente no logout

### ✅ Sistema de Timeout Otimizado
- Removido ping timeout de 60 segundos
- Aumentado connection timeout para 5 minutos
- Sistema AFK de 30 minutos (configurável)
- Sem desconexões inesperadas

### ✅ Debug Logs
- Logs detalhados para SQL queries
- Logs de conexão e desconexão
- Logs de kick por AFK

## 🔧 Troubleshooting

### Servidor não inicia

```bash
# Verifique se o MySQL está rodando
sudo systemctl status mysql

# Verifique as permissões do socket
ls -la /var/run/mysqld/mysqld.sock
```

### Cliente não conecta

1. Verifique se o IP e porta estão corretos no `config.lua`
2. Verifique se o firewall está liberado:
   ```bash
   sudo ufw allow 7171
   sudo ufw allow 7172
   ```
3. Certifique-se de que o cliente está configurado para protocolo 772

### Player desconectando

- Verifique o `kickIdlePlayerAfterMinutes` no `config.lua`
- Verifique os logs do servidor: `cat server.log | grep KICK`

## 📚 Documentação

- [Wiki Oficial do OTServ](https://otland.net/forums/)
- [OTClient Documentation](https://github.com/edubart/otclient/wiki)
- [MyAAC Documentation](https://my-aac.org/)

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## 📄 Licença

Este projeto está sob a licença GPL 2.0. Veja o arquivo `LICENSE` para mais detalhes.

## 👥 Créditos

- **Nostalrius Team** - Servidor base
- **OTLand Community** - Suporte e documentação
- **mehah** - OTClient moderno

## 📧 Contato

Para suporte ou dúvidas, abra uma issue no GitHub.

---

**⚠️ Aviso Legal:** Este projeto é apenas para fins educacionais. Tibia é uma marca registrada da CipSoft GmbH.
