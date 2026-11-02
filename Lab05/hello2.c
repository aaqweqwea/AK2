// SPDX-License-Identifier: GPL-2.0
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/errno.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>

#include "hello1.h"

static unsigned int count = 1;
module_param(count, uint, 0444);
MODULE_PARM_DESC(count, "Number of calls to print_hello (0..10)");

static int __init hello2_init(void)
{
	unsigned int remaining = count;
	int result;

	if (count > 10) {
		pr_err("count %u exceeds 10\n", count);
		return -EINVAL;
	}
	if (!count || count >= 5)
		pr_warn("unusual count %u\n", count);

	while (remaining) {
		result = print_hello();
		if (result)
			return result;
		--remaining;
	}
	pr_info("completed %u calls\n", count);
	return 0;
}

static void __exit hello2_exit(void)
{
	pr_info("consumer detached\n");
}

module_init(hello2_init);
module_exit(hello2_exit);
MODULE_AUTHOR("Oleksandr Zaviriukha");
MODULE_DESCRIPTION("Parameterized client of the exported greeting service");
MODULE_LICENSE("GPL");
