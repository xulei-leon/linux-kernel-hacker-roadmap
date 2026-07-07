#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>
#include <linux/string.h>

struct demo_object {
	u32 id;
	char payload[64];
};

static struct kmem_cache *demo_cache;
static struct demo_object *saved;

static bool keep_allocated = true;
module_param(keep_allocated, bool, 0644);
MODULE_PARM_DESC(keep_allocated, "Keep one object allocated until module unload");

static int __init slab_lifecycle_demo_init(void)
{
	demo_cache = kmem_cache_create("slab_lifecycle_demo",
				       sizeof(struct demo_object), 0,
				       SLAB_HWCACHE_ALIGN, NULL);
	if (!demo_cache)
		return -ENOMEM;

	saved = kmem_cache_zalloc(demo_cache, GFP_KERNEL);
	if (!saved) {
		kmem_cache_destroy(demo_cache);
		return -ENOMEM;
	}

	saved->id = 42;
	strscpy(saved->payload, "owned by slab_lifecycle_demo", sizeof(saved->payload));
	pr_info("slab_lifecycle_demo: allocated object=%p id=%u cache=slab_lifecycle_demo\n",
		saved, saved->id);

	if (!keep_allocated) {
		kmem_cache_free(demo_cache, saved);
		pr_info("slab_lifecycle_demo: freed object during init\n");
		saved = NULL;
	}

	return 0;
}

static void __exit slab_lifecycle_demo_exit(void)
{
	if (saved) {
		pr_info("slab_lifecycle_demo: freeing object=%p id=%u\n", saved, saved->id);
		kmem_cache_free(demo_cache, saved);
	}

	kmem_cache_destroy(demo_cache);
	pr_info("slab_lifecycle_demo: unloaded\n");
}

module_init(slab_lifecycle_demo_init);
module_exit(slab_lifecycle_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 11 slab object lifecycle demo module");
