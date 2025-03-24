ethereum_package_input_parser = import_module(
    "github.com/ethpandaops/ethereum-package/src/package_io/input_parser.star"
)

sanity_check = import_module("./sanity_check.star")

DEFAULT_EL_IMAGES = {
    "op-geth": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest",
    "op-reth": "ghcr.io/paradigmxyz/op-reth:latest",
    "op-erigon": "testinprod/op-erigon:latest",
    "op-nethermind": "nethermind/nethermind:latest",
    "op-besu": "ghcr.io/optimism-java/op-besu:latest",
}

DEFAULT_CL_IMAGES = {
    "op-node": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:develop",
    "hildr": "ghcr.io/optimism-java/hildr:latest",
}

DEFAULT_BATCHER_IMAGES = {
    "op-batcher": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-batcher:develop",
}

DEFAULT_CHALLENGER_IMAGES = {
    "op-challenger": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-challenger:develop",
}

DEFAULT_SUPERVISOR_IMAGES = {
    "op-supervisor": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-supervisor:develop",
}

DEFAULT_PROPOSER_IMAGES = {
    "op-proposer": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-proposer:develop",
}


DEFAULT_SEQUENCER_IMAGES = {
    "op-sequencer": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-proposer:develop",
}

DEFAULT_SIDECAR_IMAGES = {
    "rollup-boost": "flashbots/rollup-boost:latest",
}

DEFAULT_DA_SERVER_PARAMS = {
    "server_endpoint": "",
}


DEFAULT_ADDITIONAL_SERVICES = []


def external_l1_network_params_input_parser(plan, input_args):
    sanity_check.external_l1_network_params_input_parser(plan, input_args)
    return struct(
        network_id=input_args["network_id"],
        rpc_kind=input_args["rpc_kind"],
        el_rpc_url=input_args["el_rpc_url"],
        el_ws_url=input_args["el_ws_url"],
        cl_rpc_url=input_args["cl_rpc_url"],
        priv_key=input_args["priv_key"],
    )


def input_parser(plan, input_args, deployment_type="devnet"):
    sanity_check.sanity_check(plan, input_args)
    results = parse_network_params(plan, input_args, deployment_type)
    plan.print(results)
    results["global_log_level"] = "info"
    results["global_node_selectors"] = {}
    results["global_tolerations"] = []
    results["persistent"] = False

    return struct(
        observability=struct(
            enabled=results["observability"]["enabled"],
            prometheus_params=struct(
                image=results["observability"]["prometheus_params"]["image"],
                storage_tsdb_retention_time=results["observability"][
                    "prometheus_params"
                ]["storage_tsdb_retention_time"],
                storage_tsdb_retention_size=results["observability"][
                    "prometheus_params"
                ]["storage_tsdb_retention_size"],
                min_cpu=results["observability"]["prometheus_params"]["min_cpu"],
                max_cpu=results["observability"]["prometheus_params"]["max_cpu"],
                min_mem=results["observability"]["prometheus_params"]["min_mem"],
                max_mem=results["observability"]["prometheus_params"]["max_mem"],
            ),
            grafana_params=struct(
                image=results["observability"]["grafana_params"]["image"],
                dashboard_sources=results["observability"]["grafana_params"][
                    "dashboard_sources"
                ],
                min_cpu=results["observability"]["grafana_params"]["min_cpu"],
                max_cpu=results["observability"]["grafana_params"]["max_cpu"],
                min_mem=results["observability"]["grafana_params"]["min_mem"],
                max_mem=results["observability"]["grafana_params"]["max_mem"],
            ),
        ),
        interop=struct(
            enabled=results["interop"]["enabled"],
            supervisor_params=struct(
                image=results["interop"]["supervisor_params"]["image"],
                dependency_set=results["interop"]["supervisor_params"][
                    "dependency_set"
                ],
                extra_params=results["interop"]["supervisor_params"]["extra_params"],
            ),
        ),
        altda_deploy_config=struct(
            use_altda=results["altda_deploy_config"]["use_altda"],
            da_commitment_type=results["altda_deploy_config"]["da_commitment_type"],
            da_challenge_window=results["altda_deploy_config"]["da_challenge_window"],
            da_resolve_window=results["altda_deploy_config"]["da_resolve_window"],
            da_bond_size=results["altda_deploy_config"]["da_bond_size"],
            da_resolver_refund_percentage=results["altda_deploy_config"][
                "da_resolver_refund_percentage"
            ],
            da_type=results["altda_deploy_config"]["da_type"],
            da_batch_submission_frequency=results["altda_deploy_config"][
                "da_batch_submission_frequency"
            ],
            da_challenge_contract_address=results["altda_deploy_config"][
                "da_challenge_contract_address"
            ],
        ),
        chains=[
            struct(
                participants=[
                    struct(
                        el_type=participant["el_type"],
                        el_image=participant["el_image"],
                        el_log_level=participant["el_log_level"],
                        el_extra_env_vars=participant["el_extra_env_vars"],
                        el_extra_labels=participant["el_extra_labels"],
                        el_extra_params=participant["el_extra_params"],
                        el_tolerations=participant["el_tolerations"],
                        el_volume_size=participant["el_volume_size"],
                        el_min_cpu=participant["el_min_cpu"],
                        el_max_cpu=participant["el_max_cpu"],
                        el_min_mem=participant["el_min_mem"],
                        el_max_mem=participant["el_max_mem"],
                        cl_type=participant["cl_type"],
                        cl_image=participant["cl_image"],
                        cl_log_level=participant["cl_log_level"],
                        cl_extra_env_vars=participant["cl_extra_env_vars"],
                        cl_extra_labels=participant["cl_extra_labels"],
                        cl_extra_params=participant["cl_extra_params"],
                        cl_tolerations=participant["cl_tolerations"],
                        cl_volume_size=participant["cl_volume_size"],
                        cl_min_cpu=participant["cl_min_cpu"],
                        cl_max_cpu=participant["cl_max_cpu"],
                        cl_min_mem=participant["cl_min_mem"],
                        cl_max_mem=participant["cl_max_mem"],
                        el_builder_type=participant["el_builder_type"],
                        el_builder_image=participant["el_builder_image"],
                        el_builder_log_level=participant["el_builder_log_level"],
                        el_builder_extra_env_vars=participant[
                            "el_builder_extra_env_vars"
                        ],
                        el_builder_extra_labels=participant["el_builder_extra_labels"],
                        el_builder_extra_params=participant["el_builder_extra_params"],
                        el_builder_tolerations=participant["el_builder_tolerations"],
                        el_builder_volume_size=participant["el_builder_volume_size"],
                        el_builder_min_cpu=participant["el_builder_min_cpu"],
                        el_builder_max_cpu=participant["el_builder_max_cpu"],
                        el_builder_min_mem=participant["el_builder_min_mem"],
                        el_builder_max_mem=participant["el_builder_max_mem"],
                        cl_builder_type=participant["cl_builder_type"],
                        cl_builder_image=participant["cl_builder_image"],
                        cl_builder_log_level=participant["cl_builder_log_level"],
                        cl_builder_extra_env_vars=participant[
                            "cl_builder_extra_env_vars"
                        ],
                        cl_builder_extra_labels=participant["cl_builder_extra_labels"],
                        cl_builder_extra_params=participant["cl_builder_extra_params"],
                        cl_builder_tolerations=participant["cl_builder_tolerations"],
                        cl_builder_volume_size=participant["cl_builder_volume_size"],
                        cl_builder_min_cpu=participant["cl_builder_min_cpu"],
                        cl_builder_max_cpu=participant["cl_builder_max_cpu"],
                        cl_builder_min_mem=participant["cl_builder_min_mem"],
                        cl_builder_max_mem=participant["cl_builder_max_mem"],
                        node_selectors=participant["node_selectors"],
                        tolerations=participant["tolerations"],
                        count=participant["count"],
                    )
                    for participant in result["participants"]
                ],
                network_params=struct(
                    network=result["network_params"]["network"],
                    network_id=result["network_params"]["network_id"],
                    seconds_per_slot=result["network_params"]["seconds_per_slot"],
                    name=result["network_params"]["name"],
                    fjord_time_offset=result["network_params"]["fjord_time_offset"],
                    granite_time_offset=result["network_params"]["granite_time_offset"],
                    holocene_time_offset=result["network_params"][
                        "holocene_time_offset"
                    ],
                    isthmus_time_offset=result["network_params"]["isthmus_time_offset"],
                    interop_time_offset=result["network_params"]["interop_time_offset"],
                    fund_dev_accounts=result["network_params"]["fund_dev_accounts"],
                    withdrawal_delay=result["network_params"]["withdrawal_delay"],
                    fee_withdrawal_network=result["network_params"][
                        "fee_withdrawal_network"
                    ],
                    dispute_game_finality_delay=result["network_params"][
                        "dispute_game_finality_delay"
                    ],
                ),
                batcher_params=struct(
                    image=result["batcher_params"]["image"],
                    private_key=result["batcher_params"]["private_key"],
                    signer_endpoint=result["batcher_params"]["signer_endpoint"],
                    signer_address=result["batcher_params"]["signer_address"],
                    extra_params=result["batcher_params"]["extra_params"],
                ),
                challenger_params=struct(
                    enabled=result["challenger_params"]["enabled"],
                    image=result["challenger_params"]["image"],
                    private_key=result["challenger_params"]["private_key"],
                    signer_endpoint=result["challenger_params"]["signer_endpoint"],
                    signer_address=result["challenger_params"]["signer_address"],
                    extra_params=result["challenger_params"]["extra_params"],
                    cannon_prestate_path=result["challenger_params"][
                        "cannon_prestate_path"
                    ],
                    cannon_prestates_url=result["challenger_params"][
                        "cannon_prestates_url"
                    ],
                    cannon_trace_types=result["challenger_params"][
                        "cannon_trace_types"
                    ],
                ),
                proposer_params=struct(
                    image=result["proposer_params"]["image"],
                    private_key=result["proposer_params"]["private_key"],
                    signer_endpoint=result["proposer_params"]["signer_endpoint"],
                    signer_address=result["proposer_params"]["signer_address"],
                    extra_params=result["proposer_params"]["extra_params"],
                    game_type=result["proposer_params"]["game_type"],
                    proposal_interval=result["proposer_params"]["proposal_interval"],
                ),
                sequencer_params=struct(
                    image=result["sequencer_params"]["image"],
                    private_key=result["sequencer_params"]["private_key"],
                    signer_endpoint=result["sequencer_params"]["signer_endpoint"],
                    signer_address=result["sequencer_params"]["signer_address"],
                    extra_params=result["sequencer_params"]["extra_params"],
                ),
                l1_proxy_admin_params=struct(
                    address=result["l1_proxy_admin_params"]["address"]
                ),
                l2_proxy_admin_params=struct(
                    address=result["l2_proxy_admin_params"]["address"]
                ),
                system_config_owner_params=struct(
                    address=result["system_config_owner_params"]["address"]
                ),
                gas_params=struct(
                    gas_limit=result["gas_params"]["gas_limit"],
                    eip_1559_denominator=result["gas_params"]["eip_1559_denominator"],
                    eip_1559_elasticity=result["gas_params"]["eip_1559_elasticity"],
                    base_fee_scalar=result["gas_params"]["base_fee_scalar"],
                    blob_base_fee_scalar=result["gas_params"]["blob_base_fee_scalar"],
                ),
                mev_params=struct(
                    rollup_boost_image=result["mev_params"]["rollup_boost_image"],
                    builder_host=result["mev_params"]["builder_host"],
                    builder_port=result["mev_params"]["builder_port"],
                ),
                da_server_params=struct(
                    server_endpoint=result["da_server_params"]["server_endpoint"],
                ),
                additional_services=result["additional_services"],
            )
            for result in results["chains"]
        ],
        op_contract_deployer_params=struct(
            image=results["op_contract_deployer_params"]["image"],
            l1_artifacts_locator=results["op_contract_deployer_params"][
                "l1_artifacts_locator"
            ],
            l2_artifacts_locator=results["op_contract_deployer_params"][
                "l2_artifacts_locator"
            ],
            global_deploy_overrides=results["op_contract_deployer_params"][
                "global_deploy_overrides"
            ],
        ),
        global_log_level=results["global_log_level"],
        global_node_selectors=results["global_node_selectors"],
        global_tolerations=results["global_tolerations"],
        persistent=results["persistent"],
        deployment_type=results["deployment_type"],
    )


def parse_network_params(plan, input_args, deployment_type):
    results = {}

    # configure deployment type
    results["deployment_type"] = deployment_type

    if (
        results["deployment_type"] != "devnet"
        and results["deployment_type"] != "testnet"
    ):
        fail(
            "Invalid deployment type '{0}'. Must be 'devnet' or 'testnet'".format(
                results["deployment_type"]
            )
        )

    # configure observability

    results["observability"] = default_observability_params()
    results["observability"].update(input_args.get("observability", {}))

    results["observability"]["prometheus_params"] = default_prometheus_params()
    results["observability"]["prometheus_params"].update(
        input_args.get("observability", {}).get("prometheus_params", {})
    )

    results["observability"]["grafana_params"] = default_grafana_params()
    results["observability"]["grafana_params"].update(
        input_args.get("observability", {}).get("grafana_params", {})
    )

    # configure interop

    results["interop"] = default_interop_params()
    results["interop"].update(input_args.get("interop", {}))

    results["interop"]["supervisor_params"] = default_supervisor_params()
    results["interop"]["supervisor_params"].update(
        input_args.get("interop", {}).get("supervisor_params", {})
    )

    # configure altda

    results["altda_deploy_config"] = default_altda_deploy_config()
    results["altda_deploy_config"].update(input_args.get("altda_deploy_config", {}))

    # configure chains

    chains = []

    seen_names = {}
    seen_network_ids = {}
    for chain in input_args.get("chains", default_chains()):
        network_params = default_network_params()
        network_params.update(chain.get("network_params", {}))

        batcher_params = default_batcher_params()
        batcher_params.update(chain.get("batcher_params", {}))

        proposer_params = default_proposer_params()
        proposer_params.update(chain.get("proposer_params", {}))

        challenger_params = default_challenger_params()
        challenger_params.update(chain.get("challenger_params", {}))

        sequencer_params = default_sequencer_params()
        sequencer_params.update(chain.get("sequencer_params", {}))

        l1_proxy_admin_params = default_l1_proxy_admin_params()
        l1_proxy_admin_params.update(chain.get("l1_proxy_admin_params", {}))

        l2_proxy_admin_params = default_l2_proxy_admin_params()
        l2_proxy_admin_params.update(chain.get("l2_proxy_admin_params", {}))

        system_config_owner_params = default_system_config_owner_params()
        system_config_owner_params.update(chain.get("system_config_owner_params", {}))

        gas_params = default_gas_params()
        gas_params.update(chain.get("gas_params", {}))

        if deployment_type == "testnet":
            check_signer_params(batcher_params, "batcher")
            check_signer_params(proposer_params, "proposer")
            check_signer_params(challenger_params, "challenger")
            check_signer_params(sequencer_params, "sequencer")

        mev_params = default_mev_params()
        mev_params.update(chain.get("mev_params", {}))
        da_server_params = default_da_server_params()
        da_server_params.update(chain.get("da_server_params", {}))

        network_name = network_params["name"]
        network_id = network_params["network_id"]

        if network_name in seen_names:
            fail("Network name {0} is duplicated".format(network_name))

        if network_id in seen_network_ids:
            fail("Network id {0} is duplicated".format(network_id))

        participants = []
        for i, p in enumerate(chain.get("participants", [default_participant()])):
            participant = default_participant()
            participant.update(p)

            el_type = participant["el_type"]
            cl_type = participant["cl_type"]
            el_image = participant["el_image"]
            if el_image == "":
                default_image = DEFAULT_EL_IMAGES.get(el_type, "")
                if default_image == "":
                    fail(
                        "{0} received an empty image name and we don't have a default for it".format(
                            el_type
                        )
                    )
                participant["el_image"] = default_image

            cl_image = participant["cl_image"]
            if cl_image == "":
                default_image = DEFAULT_CL_IMAGES.get(cl_type, "")
                if default_image == "":
                    fail(
                        "{0} received an empty image name and we don't have a default for it".format(
                            cl_type
                        )
                    )
                participant["cl_image"] = default_image

            el_builder_type = participant["el_builder_type"]
            el_builder_image = participant["el_builder_image"]
            if el_builder_image == "":
                default_image = DEFAULT_EL_IMAGES.get(el_builder_type, "")
                if default_image == "":
                    fail(
                        "{0} received an empty image name and we don't have a default for it".format(
                            el_builder_type
                        )
                    )
                participant["el_builder_image"] = default_image

            cl_builder_type = participant["cl_builder_type"]
            cl_builder_image = participant["cl_builder_image"]
            if cl_builder_image == "":
                default_image = DEFAULT_CL_IMAGES.get(cl_builder_type, "")
                if default_image == "":
                    fail(
                        "{0} received an empty image name and we don't have a default for it".format(
                            cl_builder_type
                        )
                    )
                participant["cl_builder_image"] = default_image

            for _ in range(0, participant["count"]):
                participant_copy = ethereum_package_input_parser.deep_copy_participant(
                    participant
                )
                participants.append(participant_copy)

        result = {
            "participants": participants,
            "network_params": network_params,
            "batcher_params": batcher_params,
            "challenger_params": challenger_params,
            "proposer_params": proposer_params,
            "sequencer_params": sequencer_params,
            "l1_proxy_admin_params": l1_proxy_admin_params,
            "l2_proxy_admin_params": l2_proxy_admin_params,
            "system_config_owner_params": system_config_owner_params,
            "gas_params": gas_params,
            "mev_params": mev_params,
            "da_server_params": da_server_params,
            "additional_services": chain.get(
                "additional_services", DEFAULT_ADDITIONAL_SERVICES
            ),
        }
        chains.append(result)

    results["chains"] = chains

    # configure op-deployer

    results["op_contract_deployer_params"] = default_op_contract_deployer_params()
    results["op_contract_deployer_params"].update(
        input_args.get("op_contract_deployer_params", {})
    )

    results["global_log_level"] = input_args.get("global_log_level", "info")

    return results


def check_signer_params(role_params, role):
    if role_params.get("private_key"):
        if role_params.get("signer_endpoint"):
            fail(role + " cannot have a private key and a signer endpoint")
        if role_params.get("signer_address"):
            fail(role + " cannot have a private key and a signer address")
    elif not role_params.get("signer_endpoint") and not role_params.get(
        "signer_address"
    ):
        fail(role + " must have a private key or a signer endpoint and address")
    else:
        if role_params.get("signer_endpoint") and not role_params.get("signer_address"):
            fail(role + " must have a signer address if it has a signer endpoint")
        elif not role_params.get("signer_endpoint") and role_params.get(
            "signer_address"
        ):
            fail(role + " must have a signer endpoint if it has a signer address")


def default_optimism_args():
    return {
        "chains": default_chains(),
        "op_contract_deployer_params": default_op_contract_deployer_params(),
        "global_log_level": "info",
        "global_node_selectors": {},
        "global_tolerations": [],
        "persistent": False,
    }


def default_observability_params():
    return {
        "enabled": True,
    }


def default_prometheus_params():
    return {
        "image": "prom/prometheus:v3.2.1",
        "storage_tsdb_retention_time": "1d",
        "storage_tsdb_retention_size": "512MB",
        "min_cpu": 10,
        "max_cpu": 1000,
        "min_mem": 128,
        "max_mem": 2048,
    }


def default_grafana_params():
    return {
        "image": "grafana/grafana:latest",
        "dashboard_sources": [
            "github.com/ethereum-optimism/grafana-dashboards-public/resources@ee47a8ec0545a06ef487ed5ec03ca692e258e5ec"
        ],
        "min_cpu": 10,
        "max_cpu": 1000,
        "min_mem": 128,
        "max_mem": 2048,
    }


def default_interop_params():
    return {
        "enabled": False,
    }


def default_altda_deploy_config():
    return {
        "use_altda": False,
        "da_type": "blobs",
        "da_commitment_type": "KeccakCommitment",
        "da_challenge_window": 100,
        "da_resolve_window": 100,
        "da_bond_size": 10000,
        "da_resolver_refund_percentage": 0,
        "da_batch_submission_frequency": 1,
        "da_challenge_contract_address": "",
    }


def default_supervisor_params():
    return {
        "image": DEFAULT_SUPERVISOR_IMAGES["op-supervisor"],
        "dependency_set": "",
        "extra_params": [],
    }


def default_mev_params():
    return {
        "rollup_boost_image": "",
        "builder_host": "",
        "builder_port": "",
    }


def default_chains():
    return [
        {
            "participants": [default_participant()],
            "network_params": default_network_params(),
            "batcher_params": default_batcher_params(),
            "proposer_params": default_proposer_params(),
            "challenger_params": default_challenger_params(),
            "sequencer_params": default_sequencer_params(),
            "l1_proxy_admin_params": default_l1_proxy_admin_params(),
            "l2_proxy_admin_params": default_l2_proxy_admin_params(),
            "system_config_owner_params": default_system_config_owner_params(),
            "gas_params": default_gas_params(),
            "mev_params": default_mev_params(),
            "da_server_params": default_da_server_params(),
            "additional_services": DEFAULT_ADDITIONAL_SERVICES,
        }
    ]


def default_network_params():
    return {
        "network": "kurtosis",
        "network_id": "2151908",
        "name": "op-kurtosis",
        "seconds_per_slot": 2,
        "fjord_time_offset": 0,
        "granite_time_offset": 0,
        "holocene_time_offset": None,
        "isthmus_time_offset": None,
        "interop_time_offset": None,
        "fund_dev_accounts": True,
        "withdrawal_delay": 604800,
        "fee_withdrawal_network": 0,
        "dispute_game_finality_delay": 302400,
    }


def default_l1_proxy_admin_params():
    return {"address": "0x255fcBEC3d6984215a97389d83f03B608A8FA452"}


def default_l2_proxy_admin_params():
    return {"address": "0x255fcBEC3d6984215a97389d83f03B608A8FA452"}


def default_system_config_owner_params():
    return {"address": "0x255fcBEC3d6984215a97389d83f03B608A8FA452"}


def default_batcher_params():
    params = {
        "image": DEFAULT_BATCHER_IMAGES["op-batcher"],
        "extra_params": [],
        "private_key": "",
        "signer_endpoint": "",
        "signer_address": "",
    }
    return params


def default_challenger_params():
    params = {
        "enabled": True,
        "image": DEFAULT_CHALLENGER_IMAGES["op-challenger"],
        "private_key": "",
        "signer_endpoint": "",
        "signer_address": "",
        "extra_params": [],
        "cannon_prestate_path": "",
        "cannon_prestates_url": "https://storage.googleapis.com/oplabs-network-data/proofs/op-program/cannon",
        "cannon_trace_types": ["cannon", "permissioned"],
    }
    return params


def default_proposer_params():
    params = {
        "image": DEFAULT_PROPOSER_IMAGES["op-proposer"],
        "extra_params": [],
        "private_key": "",
        "signer_endpoint": "",
        "signer_address": "",
        "game_type": 1,
        "proposal_interval": "10m",
    }
    return params


def default_sequencer_params():
    params = {
        "image": DEFAULT_SEQUENCER_IMAGES["op-sequencer"],
        "extra_params": [],
        "private_key": "",
        "signer_endpoint": "",
        "signer_address": "",
    }
    return params


def default_participant():
    return {
        "el_type": "op-geth",
        "el_image": "",
        "el_log_level": "",
        "el_extra_env_vars": {},
        "el_extra_labels": {},
        "el_extra_params": [],
        "el_tolerations": [],
        "el_volume_size": 0,
        "el_min_cpu": 0,
        "el_max_cpu": 0,
        "el_min_mem": 0,
        "el_max_mem": 0,
        "cl_type": "op-node",
        "cl_image": "",
        "cl_log_level": "",
        "cl_extra_env_vars": {},
        "cl_extra_labels": {},
        "cl_extra_params": [],
        "cl_tolerations": [],
        "cl_volume_size": 0,
        "cl_min_cpu": 0,
        "cl_max_cpu": 0,
        "cl_min_mem": 0,
        "cl_max_mem": 0,
        "el_builder_type": "op-geth",
        "el_builder_image": "",
        "el_builder_log_level": "",
        "el_builder_extra_env_vars": {},
        "el_builder_extra_labels": {},
        "el_builder_extra_params": [],
        "el_builder_tolerations": [],
        "el_builder_volume_size": 0,
        "el_builder_min_cpu": 0,
        "el_builder_max_cpu": 0,
        "el_builder_min_mem": 0,
        "el_builder_max_mem": 0,
        "cl_builder_type": "op-node",
        "cl_builder_image": "",
        "cl_builder_log_level": "",
        "cl_builder_extra_env_vars": {},
        "cl_builder_extra_labels": {},
        "cl_builder_extra_params": [],
        "cl_builder_tolerations": [],
        "cl_builder_volume_size": 0,
        "cl_builder_min_cpu": 0,
        "cl_builder_max_cpu": 0,
        "cl_builder_min_mem": 0,
        "cl_builder_max_mem": 0,
        "node_selectors": {},
        "tolerations": [],
        "count": 1,
    }


def default_op_contract_deployer_global_deploy_overrides():
    return {
        "faultGameAbsolutePrestate": "",
    }


def default_op_contract_deployer_params():
    return {
        "image": "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-deployer:v0.0.12",
        "l1_artifacts_locator": "https://storage.googleapis.com/oplabs-contract-artifacts/artifacts-v1-fffcbb0ebf7f83311791534a41e65ef90df47797f9ca8f86941452f597f7128c.tar.gz",
        "l2_artifacts_locator": "https://storage.googleapis.com/oplabs-contract-artifacts/artifacts-v1-fffcbb0ebf7f83311791534a41e65ef90df47797f9ca8f86941452f597f7128c.tar.gz",
        "global_deploy_overrides": default_op_contract_deployer_global_deploy_overrides(),
    }


def default_ethereum_package_participants():
    return {
        "participants": [
            {
                "el_type": "geth",
                "cl_type": "teku",
                "cl_image": "consensys/teku:latest-amd64",
            }
        ]
    }


def default_ethereum_package_network_params():
    return {
        "network_params": {
            "preset": "minimal",
            "genesis_delay": 5,
            # Preload the Arachnid CREATE2 deployer
            "additional_preloaded_contracts": json.encode(
                {
                    "0x4e59b44847b379578588920cA78FbF26c0B4956C": {
                        "balance": "0ETH",
                        "code": "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3",
                        "storage": {},
                        "nonce": "1",
                    }
                }
            ),
        }
    }


def default_da_server_params():
    return {
        "server_endpoint": "",
    }


def default_gas_params():
    return {
        "gas_limit": "0x17D7840",
        "eip_1559_denominator": 50,
        "eip_1559_elasticity": 6,
        "base_fee_scalar": 2,
        "blob_base_fee_scalar": 1,
    }
