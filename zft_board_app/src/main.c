/*
 * Copyright (c) 2021 Nordic Semiconductor ASA
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(main, 3);

int main(void)
{
	while(true)
	{
		LOG_INF("PING!");
		printf("PINT\n");
		k_sleep(K_SECONDS(1));
	}
}

