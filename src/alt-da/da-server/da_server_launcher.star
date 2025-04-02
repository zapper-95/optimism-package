constants = import_module(
    "github.com/ethpandaops/ethereum-package/src/package_io/constants.star"
)

shared_utils = import_module(
    "github.com/ethpandaops/ethereum-package/src/shared_utils/shared_utils.star"
)

DA_SERVER_TEST_IMAGE = (
    "us-docker.pkg.dev/oplabs-tools-artifacts/images/da-server:v0.1.0"
)

# Port IDs
DA_SERVER_HTTP_PORT_ID = "http"

# Port nums
DA_SERVER_HTTP_PORT_NUM = 3100


def get_used_ports():
    used_ports = {
        DA_SERVER_HTTP_PORT_ID: shared_utils.new_port_spec(
            DA_SERVER_HTTP_PORT_NUM,
            shared_utils.TCP_PROTOCOL,
            shared_utils.HTTP_APPLICATION_PROTOCOL,
        ),
    }
    return used_ports


def get_enabled_da_server_context(
    plan,
    service_name,
    server_endpoint,
):
    plan.print("Server endpoint: {0}".format(server_endpoint))
    # if using "custom" da-type, the server endpoint is provided
    return new_da_server_context(
        http_url=server_endpoint,
    )


def disabled_da_server_context():
    return new_da_server_context(
        http_url="",
    )


def new_da_server_context(http_url):
    return struct(
        enabled=http_url != "",
        http_url=http_url,
    )


def launch_da_server(
    plan,
    service_name,
):
    config = get_da_server_config(
        plan,
        service_name,
    )

    da_server_service = plan.add_service(service_name, config)

    http_url = "http://{0}:{1}".format(
        da_server_service.ip_address, DA_SERVER_HTTP_PORT_NUM
    )
    # da_server_context is passed as argument to op-batcher and op-node(s)
    return new_da_server_context(
        http_url=http_url,
    )


def get_da_server_config(
    plan,
    service_name,
):
    ports = get_used_ports()

    return ServiceConfig(
        image=DA_SERVER_TEST_IMAGE,
        ports=ports,
        cmd=[
            "da-server",
            "--file.path=/home",
            "--addr=0.0.0.0",
            "--port=3100",
            "--log.level=debug",
        ],
        private_ip_address_placeholder=constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
    )
